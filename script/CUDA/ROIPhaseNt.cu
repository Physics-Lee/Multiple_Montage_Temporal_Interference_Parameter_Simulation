#include <stdlib.h>
#include <stdio.h>
#include <string.h>
/* Using updated (v2) interfaces to cublas */
#include <cuda_runtime.h>
#include <cusparse.h>
#include <cublas_v2.h>
// MATLAB related
#include "mex.h"
#include "gpu/mxGPUArray.h"
#include "mxShowCriticalErrorMessage.c"
#include "ROIKernel.cuh"

#define	NE_MX	prhs[0]
#define	E0	    prhs[1]
#define	ELEC	prhs[2]
#define	CU	    prhs[3]
#define	VOLUME	prhs[4]
#define	THRES	prhs[5]
#define	ALPHA	prhs[6]

#define	K_MX	prhs[7]
#define	VFLAG	prhs[8]
#define	BLOCKSIZE	prhs[9]

#define	RETVAL1	plhs[0]
// #define	RETVAL2	plhs[1]

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    // =========================================================================
    // initial
    // =========================================================================
    mxInitGPU();
    float time, timePrepare, timeKernel, timeRest;
    timeKernel = 0;
    timeRest = 0;
    cublasHandle_t cublasHandle = 0;
    cublasStatus_t cublasStatus;
    cublasStatus = cublasCreate(&cublasHandle);
    cudaError_t cudaStatus;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    const mwSize ndim = 1;
    mwSize dims[ndim];
    // -------------------------------------------------------------------------
    // vflag, blockSize
    // -------------------------------------------------------------------------
    bool vflag = *(bool*)mxGetData(VFLAG);
    int blockSize = *(int*)mxGetData(BLOCKSIZE);
    // =========================================================================
    // N, N128, E0
    // =========================================================================
    if (vflag)cudaEventRecord(start, 0);
    int N = *(int*)mxGetData(NE_MX); 
    mxGPUArray const *e0 = mxGPUCreateFromMxArray(E0);
    float *d_e0 = (float*)mxGPUGetDataReadOnly(e0);
    const mwSize *dim0 = mxGetDimensions(E0);
    const int L = dim0[1];
    const int N128 = dim0[0]; 
    // -------------------------------------------------------------------------
    // electrode
    // -------------------------------------------------------------------------
    mxGPUArray const *elec = mxGPUCreateFromMxArray(ELEC);
    int Nelec = mxGetM(ELEC);
    int * d_elec = (int*)mxGPUGetDataReadOnly(elec);
    // -------------------------------------------------------------------------
    // current
    // -------------------------------------------------------------------------
    mxGPUArray const *cu = mxGPUCreateFromMxArray(CU);
    float* d_cu = (float*)mxGPUGetDataReadOnly(cu);  
    int Ncu = (int)mxGetNumberOfElements(CU);
    int Nm = Ncu * Nelec;
    cudaStatus = cudaMemcpyToSymbol(cuConst, d_cu, sizeof(float) * Ncu);
    if (cudaStatus != cudaSuccess) mxShowCriticalErrorMessage("cudaMemcpyToSymbol failed");
    // -------------------------------------------------------------------------
    // volume
    // -------------------------------------------------------------------------// =========================================================================
    mxGPUArray const *volume = mxGPUCreateFromMxArray(VOLUME);
    float *d_volume = (float*)mxGPUGetDataReadOnly(volume);
    int Nvolume = mxGetM(VOLUME);
    // -------------------------------------------------------------------------
    // thres, alpha
    // -------------------------------------------------------------------------
    float thres = *(float*)mxGetData(THRES); 
    int alpha = *(int*)mxGetData(ALPHA); 
    // -------------------------------------------------------------------------
    // K loop num
    // -------------------------------------------------------------------------
    int K = *(int*)mxGetData(K_MX); 
    // -------------------------------------------------------------------------
    // display fundimental data information
    // -------------------------------------------------------------------------
    if(vflag){
        mexPrintf("Leadfield element number: %d\n", N); ;
        mexPrintf("Leadfield element number with padding: %d\n", N128);
        mexPrintf("Volume element Number: %d\n", Nvolume);
        mexPrintf("Electrode pool number: %d\n", L);
        mexPrintf("Electrode combination number: %d\n", Nelec);
        mexPrintf("Current type number: %d\n", Ncu);
        mexPrintf("Montage number: %d\n", Nm);
        mexPrintf("threshold: %3.3f\n", thres);
        switch(alpha){
            case -1:
                mexPrintf("Output is the MAX value in the region.\n");
                break;
            case 0:
                mexPrintf("Output is VOLUME above thres in the region.\n");
                break;
            default:
                mexPrintf("Output is Volume Weighted Summation in the region.\n");
        }
        cudaEventRecord(stop, 0);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&time, start, stop);
        timePrepare = time;
        mexPrintf("prepare time:  %3.3f ms \n",timePrepare);
        mexEvalString("drawnow") ;
    }
    // =========================================================================
    // predefine return r1 and internal r2
    // =========================================================================
    dims[0] = Nm;
    mxGPUArray * r1 = mxGPUCreateGPUArray(ndim, dims, mxSINGLE_CLASS, mxREAL, MX_GPU_INITIALIZE_VALUES);
    if (r1==NULL) mxShowCriticalErrorMessage("mxGPUCreateGPUArray failed");
    float *d_r1 = (float*)mxGPUGetData(r1);
    int r2Size = N128/blockSize*K;
    dims[0] = r2Size;
    mxGPUArray * r2 = mxGPUCreateGPUArray(ndim, dims, mxSINGLE_CLASS, mxREAL, MX_GPU_INITIALIZE_VALUES);
    if (r2==NULL) mxShowCriticalErrorMessage("mxGPUCreateGPUArray failed");
    float *d_r2 = (float*)mxGPUGetData(r2);
    // -------------------------------------------------------------------------
    // interval r3 is for check
    // -------------------------------------------------------------------------
    int r3Size = N128*K;
    dims[0] = r3Size;
    mxGPUArray * r3 = mxGPUCreateGPUArray(ndim, dims, mxSINGLE_CLASS, mxREAL, MX_GPU_INITIALIZE_VALUES);
    if (r3==NULL) mxShowCriticalErrorMessage("mxGPUCreateGPUArray failed");
    float *d_r3 = (float*)mxGPUGetData(r3);
    if(vflag)mexPrintf("r3Size:  %d\n", r3Size);
    // =========================================================================
    // process
    // =========================================================================
    int Nloop = Nelec/K+1;
    int Nlast = Nelec % K;
    int Ki = 0;
    for (int i = 0; i<Nloop; i++){
        if(vflag)cudaEventRecord(start, 0);
        if(i<Nloop-1) Ki = K;
        else Ki = Nlast;
        if (Ki == 0) break;
        int Cbase = i*K;
        int N1 = N128 / blockSize;
        int gridSize = N128/blockSize*Ki;
        if(i==0){
            if(vflag){
                mexPrintf("blockSize:  %d, gridSize: %d \n", blockSize,gridSize);
                mexPrintf("Nloop: %d, Ki:  %d\n", Nloop, Ki);
                mexEvalString("drawnow") ;
            }
        }
        unsigned sharedMemSize = blockSize * sizeof(float);
        switch(alpha){
            case -1:
                ROIMaxNtKernel<<<gridSize, blockSize,sharedMemSize>>>(Ki, Cbase, N128, d_e0, Nelec, d_elec, Ncu, d_r2);
                break;
            case 0:
                ROIVolumeNtKernel<<<gridSize, blockSize,sharedMemSize>>>(Ki, Cbase, N128, d_e0, Nelec, d_elec, Ncu, d_volume, thres, d_r2);
                break;
            default:
                ROIAlphaNtKernel<<<gridSize, blockSize,sharedMemSize>>>(Ki, Cbase, N128, d_e0, Nelec, d_elec, Ncu, d_volume, alpha, d_r2);
        }
        cudaDeviceSynchronize();   
        if(vflag){ 
            cudaEventRecord(stop, 0);
            cudaEventSynchronize(stop);
            cudaEventElapsedTime(&time, start, stop);
            timeKernel += time;
        }
        // if(i==0)RETVAL2 = mxGPUCreateMxArrayOnCPU(r2); 
        // =====================================================================
        // Rest reduction
        // =====================================================================
        int M = Ki*Ncu;
        if(vflag)cudaEventRecord(start, 0); 
        int blockSize1 = 8;
        int gridSize1 = (M + blockSize1 - 1) / blockSize1;
        if(alpha>-1)getSum<<<gridSize1,blockSize1>>>(N1, M, Ki, Cbase, Nelec, d_r2, d_r1);
        else getMax<<<gridSize1,blockSize1>>>(N1, M, Ki, Cbase, Nelec, d_r2, d_r1);  
        cudaDeviceSynchronize();
        if (vflag){
            cudaEventRecord(stop, 0);
            cudaEventSynchronize(stop);
            cudaEventElapsedTime(&time, start, stop);
            timeRest += time;
        }
    }
    // -------------------------------------------------------------------------
    // divide sum volume
    // -------------------------------------------------------------------------
    if(alpha>-1){
        float volumeSum;
        cublasStatus = cublasSasum(cublasHandle, N, d_volume, 1, &volumeSum);
        if (cublasStatus!= CUBLAS_STATUS_SUCCESS) mxShowCriticalErrorMessage("cublasSasum in volume failed");
        volumeSum = 1/volumeSum;
        cublasStatus = cublasSscal(cublasHandle, Nm, &volumeSum, d_r1, 1);
        if (cublasStatus!= CUBLAS_STATUS_SUCCESS) mxShowCriticalErrorMessage("cublasSscal in volume scale failed");
    }
    // =========================================================================
    // output
    // =========================================================================
    RETVAL1 = mxGPUCreateMxArrayOnCPU(r1);
    // =========================================================================
    // destroy
    // =========================================================================
    mxGPUDestroyGPUArray(r2);
    mxGPUDestroyGPUArray(r1);
    mxGPUDestroyGPUArray(e0);
    mxGPUDestroyGPUArray(elec);
    mxGPUDestroyGPUArray(cu);
    mxGPUDestroyGPUArray(volume);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cublasDestroy(cublasHandle);
    if(vflag){
        mexPrintf("Kernel time:  %3.3f ms \n",timeKernel);
        mexEvalString("drawnow") ;
        mexPrintf("Rest reduction time:  %3.3f ms \n",timeRest);
        mexEvalString("drawnow") ;
        mexPrintf("ROI with NT phase GPU part end...\n");
    }
}
  