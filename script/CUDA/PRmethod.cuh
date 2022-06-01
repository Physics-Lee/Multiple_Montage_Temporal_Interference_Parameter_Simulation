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
__device__ void warpReduceMax(volatile float *sdata, unsigned int tid) 
{
    sdata[tid] = fmaxf(sdata[tid],sdata[tid+32]);
    sdata[tid] = fmaxf(sdata[tid],sdata[tid+16]);
    sdata[tid] = fmaxf(sdata[tid],sdata[tid+8]);
    sdata[tid] = fmaxf(sdata[tid],sdata[tid+4]);
    sdata[tid] = fmaxf(sdata[tid],sdata[tid+2]);
    sdata[tid] = fmaxf(sdata[tid],sdata[tid+1]);
}
__device__ void warpReduceSum(volatile float *sdata, unsigned int tid) 
{
    sdata[tid] += sdata[tid+32];
    sdata[tid] += sdata[tid+16];
    sdata[tid] += sdata[tid+8];
    sdata[tid] += sdata[tid+4];
    sdata[tid] += sdata[tid+2];
    sdata[tid] += sdata[tid+1];
}

