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

#define	N_MX	prhs[0]
#define	E0	    prhs[1]
#define	C_MX	prhs[2]
#define	BETA_MX	prhs[3]
#define	K_MX	prhs[4]
#define	VFLAG	prhs[5]
#define	BLOCKSIZE	prhs[6]

#define	RETVAL1	plhs[0]
//#define	RETVAL2	plhs[1]

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    bool vflag = *(bool*)mxGetData(VFLAG);
    int blockSize = *(int*)mxGetData(BLOCKSIZE);
    // =========================================================================
    // initial
    // =========================================================================
    mxInitGPU();
    float time,timePrepare,timeKernel,timeRest;
    timeKernel = 0;
    timeRest = 0;
    cublasHandle_t cublasHandle = 0;
    cudaError_t cudaStatus;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    const mwSize ndim = 1;
    mwSize dims[ndim];
    // =========================================================================
    // input N,E0
    // =========================================================================
    int N = *(int*)mxGetData(N_MX); 
    if (vflag)cudaEventRecord(start, 0);
    mxGPUArray const *e0 = mxGPUCreateFromMxArray(E0);
    float *d_e0 = (float*)mxGPUGetDataReadOnly(e0);
    const mwSize *dim0 = mxGetDimensions(E0);
    const int L = dim0[1]; 
    const int N128 = dim0[0]; 
    if(vflag)mexPrintf("N: %d  N128: %d  L: %d\n",N,N128,L);
    // =========================================================================
    // input C_MX
    // =========================================================================
    mxGPUArray const *c = mxGPUCreateFromMxArray(C_MX);
    int Nc = mxGetM(C_MX);
    int * d_c = (int*)mxGPUGetDataReadOnly(c);
    if(vflag)mexPrintf("Nc: %d\n",Nc);
    // =========================================================================
    // input beta
    // =========================================================================
    mxGPUArray const *beta = mxGPUCreateFromMxArray(BETA_MX);
    float* d_beta = (float*)mxGPUGetDataReadOnly(beta);  
    int Nbeta = (int)mxGetNumberOfElements(BETA_MX);
    cudaStatus = cudaMemcpyToSymbol(betaConst, d_beta, sizeof(float) * Nbeta);
    if (cudaStatus != cudaSuccess) mxShowCriticalErrorMessage("cudaMemcpyToSymbol failed");
    // =========================================================================
    // input area,K
    // =========================================================================
    int K = *(int*)mxGetData(K_MX); 
    // =========================================================================
    // predefine return b and internal r
    // =========================================================================
    dims[0] = Nbeta * Nc;
    mxGPUArray * b = mxGPUCreateGPUArray(ndim, dims, mxSINGLE_CLASS, mxREAL, MX_GPU_INITIALIZE_VALUES);
    if (b==NULL) mxShowCriticalErrorMessage("mxGPUCreateGPUArray failed");
    float *d_b = (float*)mxGPUGetData(b);
    int rSize = N128/blockSize*K;
    dims[0] = rSize;
    mxGPUArray * r = mxGPUCreateGPUArray(ndim, dims, mxSINGLE_CLASS, mxREAL, MX_GPU_INITIALIZE_VALUES);
    if (r==NULL) mxShowCriticalErrorMessage("mxGPUCreateGPUArray failed");
    float *d_r = (float*)mxGPUGetData(r);
    // =========================================================================
    // kernel
    // =========================================================================
    if(vflag){
        mexPrintf("Object in ROI with prefered orientation is MAX form\n");
        mexPrintf("Area is useless.\n"); 
        cudaEventRecord(stop, 0);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&time, start, stop);
        timePrepare = time;
        mexPrintf("prepare time:  %3.3f ms \n",timePrepare);
        mexEvalString("drawnow") ;
    }

    int Nloop = Nc/K+1;
    int Nlast = Nc % K;
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
        ROIMaxNtKernel<<<gridSize, blockSize,sharedMemSize>>>(N128, Ki, Nc, d_e0, d_c, Cbase, Nbeta, d_r);
        cudaDeviceSynchronize();   
        if(vflag){ 
            cudaEventRecord(stop, 0);
            cudaEventSynchronize(stop);
            cudaEventElapsedTime(&time, start, stop);
            timeKernel += time;
        }
        //if(i==0)RETVAL2 = mxGPUCreateMxArrayOnCPU(r); 
        // =====================================================================
        // rest Max
        // =====================================================================
        int M = Ki*Nbeta;
        if(vflag)cudaEventRecord(start, 0); 
        int blockSize1 = 8;
        int gridSize1 = (M + blockSize1 - 1) / blockSize1;
        getMax<<<gridSize1,blockSize1>>>(N1, M, Ki, Cbase, Nc, d_r, d_b);  
        cudaDeviceSynchronize();
        if (vflag){
            cudaEventRecord(stop, 0);
            cudaEventSynchronize(stop);
            cudaEventElapsedTime(&time, start, stop);
            timeRest += time;
        }
    }
    // =========================================================================
    // output
    // =========================================================================
    RETVAL1 = mxGPUCreateMxArrayOnCPU(b);
    // =========================================================================
    // destroy
    // =========================================================================
    mxGPUDestroyGPUArray(r);
    mxGPUDestroyGPUArray(b);
    mxGPUDestroyGPUArray(e0);
    mxGPUDestroyGPUArray(c);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cublasDestroy(cublasHandle);
    if(vflag){
        mexPrintf("Kernel time:  %3.3f ms \n",timeKernel);
        mexEvalString("drawnow") ;
        mexPrintf("Rest Max time:  %3.3f ms \n",timeRest);
        mexEvalString("drawnow") ;
        mexPrintf("ROI Max with prefered orientation GPU part end...\n");
    }
}
  