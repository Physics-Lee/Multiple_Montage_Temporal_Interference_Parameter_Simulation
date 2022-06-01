#pragma once
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
#include "MultiElecNtKernel.cuh"

#define	NE_MX	prhs[0]
#define	E0	    prhs[1]
#define	ELECA 	prhs[2]
#define	ELECB 	prhs[3]
#define	CUA	    prhs[4]
#define	CUB	    prhs[5]
#define	VOLUME	prhs[6]
#define	THRES	prhs[7]
#define	ALPHA	prhs[8]

#define	K_MX	prhs[9]
#define	VFLAG	prhs[10]
#define	BLOCKSIZE	prhs[11]

#define	RETVAL1	plhs[0]
#define	RETVAL2	plhs[1]
// #define	RETVAL3	plhs[2]

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    // -------------------------------------------------------------------------
    // vflag, blockSize
    // -------------------------------------------------------------------------
    bool vflag = *(bool*)mxGetData(VFLAG);
    int blockSize = *(int*)mxGetData(BLOCKSIZE);
    // -------------------------------------------------------------------------
    // initial
    // -------------------------------------------------------------------------
    mxInitGPU();
    cublasHandle_t cublasHandle = 0;
    cublasStatus_t cublasStatus;
    cublasStatus = cublasCreate(&cublasHandle);
    float time, timePrepare, timeKernel, timeRest;
    timeKernel = 0;
    timeRest = 0;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    const mwSize ndim = 1;
    mwSize dims[ndim];  
    // -------------------------------------------------------------------------
    // N, N128, E0
    // -------------------------------------------------------------------------
    cudaEventRecord(start, 0);
    int N = *(int*)mxGetData(NE_MX); 
    mxGPUArray const *e0 = mxGPUCreateFromMxArray(E0);
    float *d_e0 = (float*)mxGPUGetDataReadOnly(e0);
    const mwSize *dim0 = mxGetDimensions(E0);
    const int L = dim0[1];
    const int N128 = dim0[0]; 
    // -------------------------------------------------------------------------
    // electrode
    // -------------------------------------------------------------------------
    mxGPUArray const *elecA = mxGPUCreateFromMxArray(ELECA);
    mxGPUArray const *elecB = mxGPUCreateFromMxArray(ELECB);
    int Nm = mxGetM(ELECA);
    int elecNumA = mxGetN(ELECA);
    int elecNumB = mxGetN(ELECB);
    int * d_elecA = (int*)mxGPUGetDataReadOnly(elecA);
    int * d_elecB = (int*)mxGPUGetDataReadOnly(elecB);
    // -------------------------------------------------------------------------
    // current
    // -------------------------------------------------------------------------
    mxGPUArray const *cuA = mxGPUCreateFromMxArray(CUA);
    float * d_cuA = (float*)mxGPUGetDataReadOnly(cuA);
    mxGPUArray const *cuB = mxGPUCreateFromMxArray(CUB);
    float * d_cuB = (float*)mxGPUGetDataReadOnly(cuB);
    // -------------------------------------------------------------------------
    // volume
    // -------------------------------------------------------------------------
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
        mexPrintf("Electrode pool number: %d\n", L);
        mexPrintf("Montage number: %d\n", Nm);
        mexPrintf("Elec A Number: %d\n", elecNumA);
        mexPrintf("Elec B Number: %d\n", elecNumB);
        mexPrintf("Volume element Number: %d\n", Nvolume);
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
    if(vflag)mexPrintf("r2Size:  %d\n", r2Size);
    // -------------------------------------------------------------------------
    // interval r3 is for check
    // -------------------------------------------------------------------------
    // int r3Size = N128*K;
    // dims[0] = r3Size;
    // mxGPUArray * r3 = mxGPUCreateGPUArray(ndim, dims, mxSINGLE_CLASS, mxREAL, MX_GPU_INITIALIZE_VALUES);
    // if (r3==NULL) mxShowCriticalErrorMessage("mxGPUCreateGPUArray failed");
    // float *d_r3 = (float*)mxGPUGetData(r3);
    // if(vflag)mexPrintf("r3Size:  %d\n", r3Size);
    // =========================================================================
    // process
    // =========================================================================
    int Nloop = Nm/K+1;
    int Nlast = Nm % K;
    int N1 = N128 / blockSize;
    int loop100 = ceil((float)Nloop/100);
    if(vflag){
        mexPrintf("Nloop:  %d, K: %d \n", Nloop,K);
        mexEvalString("drawnow") ;
    }
    int Ki = 0;
    for (int i = 0; i<Nloop; i++){
        if(vflag)cudaEventRecord(start, 0);
        if(i<Nloop-1) Ki = K;
        else Ki = Nlast;
        if (Ki == 0) break;
        int Mbase = i*K;  
        int gridSize = N128/blockSize*Ki;
        if(i==0){
            if(vflag){
                mexPrintf("blockSize:  %d, gridSize: %d\n", blockSize, gridSize);
                mexEvalString("drawnow") ;
            }
        }
        if(i==loop100){
            if(vflag){
                mexPrintf("The time consumption of %d loops is about %3.3f ms \n", loop100, timeKernel + timeRest);
                mexEvalString("drawnow") ;
            } 
        }
        unsigned sharedMemSize = blockSize*sizeof(float);
        switch(alpha){
            case -1:
                MultiMaxNtKernel<<<gridSize, blockSize, sharedMemSize>>>(N128, d_e0, Nm, elecNumA, elecNumB, d_elecA, d_elecB, d_cuA, d_cuB, Mbase, d_r2);
                break;
            case 0:
                MultiVolumeNtKernel<<<gridSize, blockSize, sharedMemSize>>>(N128, d_e0, Nm, elecNumA, elecNumB, d_elecA, d_elecB, d_cuA, d_cuB, Mbase, d_volume, thres, d_r2);
                break;
            default:
                MultiAlphaNtKernel<<<gridSize, blockSize, sharedMemSize>>>(N128, d_e0, Nm, elecNumA, elecNumB, d_elecA, d_elecB, d_cuA, d_cuB, Mbase, d_volume, alpha, d_r2);
        }
        cudaDeviceSynchronize();   
        if(vflag){ 
            cudaEventRecord(stop, 0);
            cudaEventSynchronize(stop);
            cudaEventElapsedTime(&time, start, stop);
            timeKernel += time;
            // mexPrintf("Kernel function finished.\n");
            // mexEvalString("drawnow") ;
        }  
        // if(i==0)RETVAL2 = mxGPUCreateMxArrayOnCPU(r2);
        // if(i==0)RETVAL3 = mxGPUCreateMxArrayOnCPU(r3);
        // ---------------------------------------------------------------------
        // Rest reduction
        // ---------------------------------------------------------------------
        if(vflag)cudaEventRecord(start, 0);        
        int blockSize1 = 8;
        int gridSize1 = (Ki + blockSize1 - 1) / blockSize1;
        if(alpha>-1)getSum<<<gridSize1,blockSize1>>>(Ki, N1, d_r2, d_r1+i*K);
        else getMax<<<gridSize1,blockSize1>>>(Ki, N1, d_r2, d_r1+i*K);
        cudaDeviceSynchronize();
        if(vflag){ 
            cudaEventRecord(stop, 0);
            cudaEventSynchronize(stop);
            cudaEventElapsedTime(&time, start, stop);
            timeRest += time;
        }  
    }   
    // divide sum volume
    if(alpha>-1){
    float volumeSum;
    cublasStatus = cublasSasum(cublasHandle, N, d_volume, 1, &volumeSum);
    if (cublasStatus!= CUBLAS_STATUS_SUCCESS) mxShowCriticalErrorMessage("cublasSasum in volume failed");
    volumeSum = 1/volumeSum;
    cublasStatus = cublasSscal(cublasHandle, Nm, &volumeSum, d_r1, 1);
    if (cublasStatus!= CUBLAS_STATUS_SUCCESS) mxShowCriticalErrorMessage("cublasSscal in volume scale failed");
    }
    RETVAL1 = mxGPUCreateMxArrayOnCPU(r1);
    // =========================================================================
    // destroy
    // =========================================================================
    if(vflag){
        mexPrintf("Kernel time:  %3.3f ms \n",timeKernel);
        mexEvalString("drawnow") ;
        mexPrintf("Rest PR time:  %3.3f ms \n",timeRest);
        mexEvalString("drawnow") ;
        mexPrintf("GPU part with NT end...\n");
    }
    // mxGPUDestroyGPUArray(r3);
    mxGPUDestroyGPUArray(r2);
    mxGPUDestroyGPUArray(r1);
    mxGPUDestroyGPUArray(volume);
    mxGPUDestroyGPUArray(elecA);
    mxGPUDestroyGPUArray(elecB);
    mxGPUDestroyGPUArray(cuA);
    mxGPUDestroyGPUArray(cuB);
    mxGPUDestroyGPUArray(e0);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cublasDestroy(cublasHandle);
}
  