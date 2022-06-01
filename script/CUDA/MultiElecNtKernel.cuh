#include "Basic2.cuh"
#include "PRmethod.cuh"
__global__ void getSum(int M, int N, float* in, float * out)
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i < M ){
        float tmp = 0;
        for(int ii = 0; ii<N; ii++){
            tmp += *(in+N*i+ii);
        }
        out[i] = tmp;
    }
}

__global__ void getMax(int M, int N, float* in, float * out)
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i < M ){
        float tmp = 0;
        float tmp1;
        for(int ii = 0; ii<N; ii++){
            tmp1 = *(in+N*i+ii);
            if (tmp < tmp1)
                tmp = tmp1;
        }
        out[i] = tmp;
    }
}
__global__ void MultiMaxNtKernel(int N, float *d_e0, int Nm, int elecNumA, int elecNumB, int* d_elecA, int* d_elecB, float* d_cuA, float* d_cuB, int Mbase, float* d_r2)                   
{
    extern __shared__ float rShare[];
    int blockPerN = N / blockDim.x;
    int bid = blockIdx.x;
    int tid = threadIdx.x;
    int ic = bid / blockPerN;
    int i = bid % blockPerN * blockDim.x + threadIdx.x;
    // int r3Idx = bid * blockDim.x + threadIdx.x;
    int *d_elec1, *d_elec2;
    float *d_cu1, *d_cu2;
    float* d_e;
    float cu = 0;
    // -------------------------------------------------------------------------
    // E in frequency a
    // -------------------------------------------------------------------------
    float eA = 0;
    d_elec1 = d_elecA+Mbase+ic;
    d_cu1 = d_cuA+Mbase+ic;
    for(int ii = 0; ii<elecNumA; ii++){
        d_elec2 = d_elec1 + Nm*ii; 
        d_e = d_e0 + N*(*d_elec2-1);
        d_cu2 = d_cu1 + Nm*ii; 
        cu = *d_cu2;
        eA = eA + d_e[i] * cu; 
    }
    // -------------------------------------------------------------------------
    // E in frequency b
    // -------------------------------------------------------------------------
    float eB = 0;
    d_elec1 = d_elecB + Mbase + ic;
    d_cu1 = d_cuB + Mbase + ic;
    for(int ii = 0; ii<elecNumB; ii++){
        d_elec2 = d_elec1 + Nm*ii; 
        d_e = d_e0+N*(*d_elec2-1);
        d_cu2 = d_cu1 + Nm*ii; 
        cu = *d_cu2;
        eB = eB + d_e[i]* cu; 
    }
    eA = abs(eA);
    eB = abs(eB);
    // d_r3[r3Idx] = r0;
    rShare[tid] = 2*min(eA,eB);
    //Parallel Reduction for max
    __syncthreads();
    for(int stride = (blockDim.x/2); stride > 32 ; stride /=2){ 
        if(tid < stride){
            rShare[tid] = fmaxf(rShare[tid],rShare[tid + stride]);
            __syncthreads();
        }
    }
    if(tid < 32) warpReduceMax(rShare,tid);
    if(tid == 0) d_r2[bid] = rShare[0]; 
}

__global__ void MultiAlphaNtKernel(int N, float *d_e0, int Nm, int elecNumA, int elecNumB, int* d_elecA, int* d_elecB, float* d_cuA, float* d_cuB, int Mbase, float* volume, int alpha, float* d_r2)                   
{
    extern __shared__ float rShare[];
    int blockPerN = N / blockDim.x;
    int bid = blockIdx.x;
    int tid = threadIdx.x;
    int ic = bid / blockPerN;
    int i = bid % blockPerN * blockDim.x + threadIdx.x;
    int *d_elec1, *d_elec2;
    float *d_cu1, *d_cu2;
    float* d_e;
    float cu = 0;
    float r0;
    // -------------------------------------------------------------------------
    // E in frequency a
    // -------------------------------------------------------------------------
    float eA = 0;
    d_elec1 = d_elecA+Mbase+ic;
    d_cu1 = d_cuA+Mbase+ic;
    for(int ii = 0; ii<elecNumA; ii++){
        d_elec2 = d_elec1 + Nm*ii; 
        d_e = d_e0 + N*(*d_elec2-1);
        d_cu2 = d_cu1 + Nm*ii; 
        cu = *d_cu2;
        eA = eA + d_e[i] * cu; 
    }
    // -------------------------------------------------------------------------
    // E in frequency b
    // -------------------------------------------------------------------------
    float eB = 0;
    d_elec1 = d_elecB + Mbase + ic;
    d_cu1 = d_cuB + Mbase + ic;
    for(int ii = 0; ii<elecNumB; ii++){
        d_elec2 = d_elec1 + Nm*ii; 
        d_e = d_e0+N*(*d_elec2-1);
        d_cu2 = d_cu1 + Nm*ii; 
        cu = *d_cu2;
        eB = eB + d_e[i]* cu; 
    } 
    if(alpha==1) rShare[tid] = 2*min(eA,eB);
    else r0 = powf(2*min(eA,eB),(float)alpha);
    rShare[tid]  = r0*volume[i];
    //Parallel Reduction for sum 
    __syncthreads();
    for(int stride = (blockDim.x/2); stride > 32 ; stride /=2){ 
        if(tid < stride){
            rShare[tid] += rShare[tid + stride];
            __syncthreads();
        }
    }
    if(tid < 32) warpReduceSum(rShare,tid);
    if(tid == 0) d_r2[bid] = rShare[0]; 
}

__global__ void MultiVolumeNtKernel(int N, float *d_e0, int Nm, int elecNumA, int elecNumB, int* d_elecA, int* d_elecB, float* d_cuA, float* d_cuB, int Mbase, float* volume, float thres, float* d_r2)                                  
{
    extern __shared__ float rShare[];
    int blockPerN = N / blockDim.x;
    int bid = blockIdx.x;
    int tid = threadIdx.x;
    int ic = bid / blockPerN;
    int i = bid % blockPerN * blockDim.x + threadIdx.x;
    int *d_elec1, *d_elec2;
    float *d_cu1, *d_cu2;
    float* d_e;
    float cu = 0;
    // -------------------------------------------------------------------------
    // E in frequency a
    // -------------------------------------------------------------------------
    float eA = 0;
    d_elec1 = d_elecA+Mbase+ic;
    d_cu1 = d_cuA+Mbase+ic;
    for(int ii = 0; ii<elecNumA; ii++){
        d_elec2 = d_elec1 + Nm*ii; 
        d_e = d_e0 + N*(*d_elec2-1);
        d_cu2 = d_cu1 + Nm*ii; 
        cu = *d_cu2;
        eA = eA + d_e[i] * cu; 
    }
    // -------------------------------------------------------------------------
    // E in frequency b
    // -------------------------------------------------------------------------
    float eB = 0;
    d_elec1 = d_elecB + Mbase + ic;
    d_cu1 = d_cuB + Mbase + ic;
    for(int ii = 0; ii<elecNumB; ii++){
        d_elec2 = d_elec1 + Nm*ii; 
        d_e = d_e0+N*(*d_elec2-1);
        d_cu2 = d_cu1 + Nm*ii; 
        cu = *d_cu2;
        eB = eB + d_e[i]* cu; 
    } 
    float r0 = 2*min(eA,eB);
    if(r0>=thres)
        rShare[tid]  = volume[i];
    else
        rShare[tid]  = 0;
    //Parallel Reduction for sum 
    __syncthreads();
    for(int stride = (blockDim.x/2); stride > 32 ; stride /=2){ 
        if(tid < stride){
            rShare[tid] += rShare[tid + stride];
            __syncthreads();
        }
    }
    if(tid < 32) warpReduceSum(rShare,tid);
    if(tid == 0) d_r2[bid] = rShare[0];     
}
