__constant__ float cuConst[32];
#include "PRmethod.cuh"
__global__ void getSum(int N, int M, int Kci, int basec, int Nelec, float* d_r, float * d_b)
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int x = i % Kci;
    int y = i / Kci;
    int offset = N*(x+y*Kci);
    x = basec + x;
    if(i < M ){
        float tmp = 0;
        for(int ii = 0; ii<N; ii++)
            tmp += *(d_r+offset+ii);
        d_b[x+y*Nelec] = tmp;
    }
}
__global__ void getMax(int N, int M, int Kci, int basec, int Nelec, float* d_r, float * d_b)
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int x = i % Kci;
    int y = i / Kci;
    int offset = N*(x+y*Kci);
    x = basec + x;
    if(i < M ){
        float tmp = 0;
        float tmp1;
        for(int ii = 0; ii<N; ii++){
            tmp1 = *(d_r+offset+ii);
            if (tmp < tmp1)
                tmp = tmp1;
        }
        d_b[x+y*Nelec] = tmp;
    }
}
__global__ void ROIMaxKernel(int Ki, int Cbase, int N, float *d_e0, int Nelec, int* d_elec, int Ncu, float * r)                   
{
    extern __shared__ float rShare[];
    int blockPerN = N / blockDim.x;
    int bid = blockIdx.x;
    int tid = threadIdx.x;
    int N3 = N*3; 
    int ic = bid / blockPerN;
    int i = bid % blockPerN * blockDim.x + threadIdx.x;
    int *idx1 = d_elec+Cbase+ic;
    int *idx2 = d_elec+Cbase+ic+Nelec;
    int *idx3 = d_elec+Cbase+ic+Nelec*2;
    int *idx4 = d_elec+Cbase+ic+Nelec*3;
    float* e1 = d_e0+N3*(*idx1-1);
    float* e2 = d_e0+N3*(*idx2-1);
    float* e3 = d_e0+N3*(*idx3-1);
    float* e4 = d_e0+N3*(*idx4-1);

    float eAx = e1[i]-e2[i];
    float eAy = e1[i+N]-e2[i+N];
    float eAz = e1[i+N*2]-e2[i+N*2];
    float eBx = e3[i]-e4[i];
    float eBy = e3[i+N]-e4[i+N];
    float eBz = e3[i+N*2]-e4[i+N*2];
    float normA = norm3df(eAx,eAy,eAz);
    float normB = norm3df(eBx,eBy,eBz); 
    // ensure alpha < pi/2
    float dot_idx = eAx*eBx+eAy*eBy+eAz*eBz;
    if (dot_idx<0)
    {
        eBx = -eBx;
        eBy = -eBy;
        eBz = -eBz;
        dot_idx = -dot_idx;
    }
    // cosalpha
    float cosalpha = dot_idx/(normA*normB);
    // loop for 21 times
    float cuA,cuB;
    for (int j = 0; j<Ncu;j++){
        cuA = cuConst[j];
        cuB = 2-cuA;
        float ax = cuA*eAx;
        float ay = cuA*eAy;
        float az = cuA*eAz;
        float bx = cuB*eBx;
        float by = cuB*eBy;
        float bz = cuB*eBz;
        float norma = cuA*normA;
        float normb = cuB*normB;
        // ensure Ea>Eb 
        if (norma<normb)
        {   
            float tmp;
            tmp = ax; ax = bx; bx = tmp;
            tmp = ay; ay = by; by = tmp;
            tmp = az; az = bz; bz = tmp;
            tmp = norma; norma = normb; normb = tmp;
        }
        if (normb>norma*cosalpha)
        {
            float cx = ax-bx;
            float cy = ay-by;
            float cz = az-bz;
            float crossx = by*cz-bz*cy;
            float crossy = bz*cx-bx*cz;
            float crossz = bx*cy-by*cx;
            float t1 = crossx*crossx+crossy*crossy+crossz*crossz;
            float t2 = cx*cx+cy*cy+cz*cz;
            rShare[tid] = 2*sqrtf(t1/t2); 
        }
        else rShare[tid] = 2*normb;
        //Parallel Reduction for max
        __syncthreads();
        for(int stride = (blockDim.x/2); stride > 32 ; stride /=2){ 
            if(tid < stride){
                rShare[tid] = fmaxf(rShare[tid],rShare[tid + stride]);
                __syncthreads();
            }
        }
        if(tid < 32) warpReduceMax(rShare,tid);
        if(tid == 0) r[bid+blockPerN*Ki*j] = rShare[0];   
    }
}
__global__ void ROIAlphaKernel(int Ki, int Cbase, int N, float *d_e0, int Nelec, int* d_elec, int Ncu, float *d_volume, int alpha, float * r)
{
    extern __shared__ float rShare[];
    int blockPerN = N / blockDim.x;
    int bid = blockIdx.x;
    int tid = threadIdx.x;
    int N3 = N*3; 
    int ic = bid / blockPerN;
    int i = bid % blockPerN * blockDim.x + threadIdx.x;
    int *idx1 = d_elec+Cbase+ic;
    int *idx2 = d_elec+Cbase+ic+Nelec;
    int *idx3 = d_elec+Cbase+ic+Nelec*2;
    int *idx4 = d_elec+Cbase+ic+Nelec*3;
    float* e1 = d_e0+N3*(*idx1-1);
    float* e2 = d_e0+N3*(*idx2-1);
    float* e3 = d_e0+N3*(*idx3-1);
    float* e4 = d_e0+N3*(*idx4-1);

    float eAx = e1[i]-e2[i];
    float eAy = e1[i+N]-e2[i+N];
    float eAz = e1[i+N*2]-e2[i+N*2];
    float eBx = e3[i]-e4[i];
    float eBy = e3[i+N]-e4[i+N];
    float eBz = e3[i+N*2]-e4[i+N*2];
    float normA = norm3df(eAx,eAy,eAz);
    float normB = norm3df(eBx,eBy,eBz); 
    // ensure alpha < pi/2
    float dot_idx = eAx*eBx+eAy*eBy+eAz*eBz;
    if (dot_idx<0)
    {
        eBx = -eBx;
        eBy = -eBy;
        eBz = -eBz;
        dot_idx = -dot_idx;
    }
    // cosalpha
    float cosalpha = dot_idx/(normA*normB);
    // loop for 21 times
    float cuA,cuB,r0;
    for (int j = 0; j<Ncu;j++){
        cuA = cuConst[j];
        cuB = 2-cuA;
        float ax = cuA*eAx;
        float ay = cuA*eAy;
        float az = cuA*eAz;
        float bx = cuB*eBx;
        float by = cuB*eBy;
        float bz = cuB*eBz;
        float norma = cuA*normA;
        float normb = cuB*normB;
        // ensure Ea>Eb 
        if (norma<normb)
        {   
            float tmp;
            tmp = ax; ax = bx; bx = tmp;
            tmp = ay; ay = by; by = tmp;
            tmp = az; az = bz; bz = tmp;
            tmp = norma; norma = normb; normb = tmp;
        }
        if (normb>norma*cosalpha)
        {
            float cx = ax-bx;
            float cy = ay-by;
            float cz = az-bz;
            float crossx = by*cz-bz*cy;
            float crossy = bz*cx-bx*cz;
            float crossz = bx*cy-by*cx;
            float t1 = crossx*crossx+crossy*crossy+crossz*crossz;
            float t2 = cx*cx+cy*cy+cz*cz;
            if(alpha==1) r0 = 2*sqrtf(t1/t2);
            else r0 = powf(2*sqrtf(t1/t2),(float)alpha);
        }
        else {
            if(alpha==1) r0 = 2*normb;
            else r0 = powf(2*normb,(float)alpha);
        }  
        rShare[tid]  = r0*d_volume[i];
        //Parallel Reduction for sum
        __syncthreads();
        for(int stride = (blockDim.x/2); stride > 32 ; stride /=2){ 
            if(tid < stride){
                rShare[tid] += rShare[tid + stride];
                __syncthreads();
            }
        }
        if(tid < 32) warpReduceSum(rShare,tid);
        if(tid == 0) r[bid+blockPerN*Ki*j] = rShare[0];   
    }
}
__global__ void ROIVolumeKernel(int Ki, int Cbase, int N, float *d_e0, int Nelec, int* d_elec, int Ncu, float *d_volume, float thres, float * r)
{
    extern __shared__ float rShare[];
    int blockPerN = N / blockDim.x;
    int bid = blockIdx.x;
    int tid = threadIdx.x;
    int N3 = N*3; 
    int ic = bid / blockPerN;
    int i = bid % blockPerN * blockDim.x + threadIdx.x;
    int *idx1 = d_elec+Cbase+ic;
    int *idx2 = d_elec+Cbase+ic+Nelec;
    int *idx3 = d_elec+Cbase+ic+Nelec*2;
    int *idx4 = d_elec+Cbase+ic+Nelec*3;
    float* e1 = d_e0+N3*(*idx1-1);
    float* e2 = d_e0+N3*(*idx2-1);
    float* e3 = d_e0+N3*(*idx3-1);
    float* e4 = d_e0+N3*(*idx4-1);

    float eAx = e1[i]-e2[i];
    float eAy = e1[i+N]-e2[i+N];
    float eAz = e1[i+N*2]-e2[i+N*2];
    float eBx = e3[i]-e4[i];
    float eBy = e3[i+N]-e4[i+N];
    float eBz = e3[i+N*2]-e4[i+N*2];
    float normA = norm3df(eAx,eAy,eAz);
    float normB = norm3df(eBx,eBy,eBz); 
    // ensure alpha < pi/2
    float dot_idx = eAx*eBx+eAy*eBy+eAz*eBz;
    if (dot_idx<0)
    {
        eBx = -eBx;
        eBy = -eBy;
        eBz = -eBz;
        dot_idx = -dot_idx;
    }
    // cosalpha
    float cosalpha = dot_idx/(normA*normB);
    // loop for 21 times
    float cuA,cuB,r0;
    for (int j = 0; j<Ncu;j++){
        cuA = cuConst[j];
        cuB = 2-cuA;
        float ax = cuA*eAx;
        float ay = cuA*eAy;
        float az = cuA*eAz;
        float bx = cuB*eBx;
        float by = cuB*eBy;
        float bz = cuB*eBz;
        float norma = cuA*normA;
        float normb = cuB*normB;
        // ensure Ea>Eb 
        if (norma<normb)
        {   
            float tmp;
            tmp = ax; ax = bx; bx = tmp;
            tmp = ay; ay = by; by = tmp;
            tmp = az; az = bz; bz = tmp;
            tmp = norma; norma = normb; normb = tmp;
        }
        if (normb>norma*cosalpha)
        {
            float cx = ax-bx;
            float cy = ay-by;
            float cz = az-bz;
            float crossx = by*cz-bz*cy;
            float crossy = bz*cx-bx*cz;
            float crossz = bx*cy-by*cx;
            float t1 = crossx*crossx+crossy*crossy+crossz*crossz;
            float t2 = cx*cx+cy*cy+cz*cz;
            r0 = 2*sqrtf(t1/t2);
        }
        else r0 = 2*normb;
        if(r0>=thres)
            rShare[tid]  = d_volume[i];
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
        if(tid == 0) r[bid+blockPerN*Ki*j] = rShare[0];   
    }
}
__global__ void ROIMaxNtKernel(int Ki, int Cbase, int N, float *d_e0, int Nelec, int* d_elec, int Ncu, float * r)                   
{
    extern __shared__ float rShare[];
    int blockPerN = N / blockDim.x;
    int bid = blockIdx.x;
    int tid = threadIdx.x;
    int ic = bid / blockPerN;
    int i = bid % blockPerN * blockDim.x + threadIdx.x;
    int *idx1 = d_elec+Cbase+ic;
    int *idx2 = d_elec+Cbase+ic+Nelec;
    int *idx3 = d_elec+Cbase+ic+Nelec*2;
    int *idx4 = d_elec+Cbase+ic+Nelec*3;
    float* e1 = d_e0+N*(*idx1-1);
    float* e2 = d_e0+N*(*idx2-1);
    float* e3 = d_e0+N*(*idx3-1);
    float* e4 = d_e0+N*(*idx4-1);
    float eA = e1[i]-e2[i];
    float eB = e3[i]-e4[i];
    eA = abs(eA);
    eB = abs(eB);
    // loop for 21 times
    float cuA,cuB;
    for (int j = 0; j<Ncu;j++){
        cuA = cuConst[j];
        cuB = 2-cuA;
        float ax = cuA*eA;
        float bx = cuB*eB;
        rShare[tid] = 2*min(ax,bx);
        //Parallel Reduction for max
        __syncthreads();
        for(int stride = (blockDim.x/2); stride > 32 ; stride /=2){ 
            if(tid < stride){
                rShare[tid] = fmaxf(rShare[tid],rShare[tid + stride]);
                __syncthreads();
            }
        }
        if(tid < 32) warpReduceMax(rShare,tid);
        if(tid == 0) r[bid+blockPerN*Ki*j] = rShare[0]; 
    }
}
__global__ void ROIVolumeNtKernel(int Ki, int Cbase, int N, float *d_e0, int Nelec, int* d_elec, int Ncu, float *d_volume, float thres, float * r)                   
{
    extern __shared__ float rShare[];
    int blockPerN = N / blockDim.x;
    int bid = blockIdx.x;
    int tid = threadIdx.x;
    int ic = bid / blockPerN;
    int i = bid % blockPerN * blockDim.x + threadIdx.x;
    int *idx1 = d_elec+Cbase+ic;
    int *idx2 = d_elec+Cbase+ic+Nelec;
    int *idx3 = d_elec+Cbase+ic+Nelec*2;
    int *idx4 = d_elec+Cbase+ic+Nelec*3;
    float* e1 = d_e0+N*(*idx1-1);
    float* e2 = d_e0+N*(*idx2-1);
    float* e3 = d_e0+N*(*idx3-1);
    float* e4 = d_e0+N*(*idx4-1);
    float eA = e1[i]-e2[i];
    float eB = e3[i]-e4[i];
    eA = abs(eA);
    eB = abs(eB);
    // loop for 21 times
    float cuA,cuB,r0;
    for (int j = 0; j<Ncu;j++){
        cuA = cuConst[j];
        cuB = 2-cuA;
        float ax = cuA*eA;
        float bx = cuB*eB;
        r0 = 2*min(ax,bx);
        if(r0>=thres)
            rShare[tid]  = d_volume[i];
        else
            rShare[tid]  = 0;
        //Parallel Reduction for max
        __syncthreads();
        for(int stride = (blockDim.x/2); stride > 32 ; stride /=2){ 
            if(tid < stride){
                rShare[tid] = fmaxf(rShare[tid],rShare[tid + stride]);
                __syncthreads();
            }
        }
        if(tid < 32) warpReduceMax(rShare,tid);
        if(tid == 0) r[bid+blockPerN*Ki*j] = rShare[0]; 
    }
}
__global__ void ROIAlphaNtKernel(int Ki, int Cbase, int N, float *d_e0, int Nelec, int* d_elec, int Ncu, float *d_volume, int alpha, float * r)
{
    extern __shared__ float rShare[];
    int blockPerN = N / blockDim.x;
    int bid = blockIdx.x;
    int tid = threadIdx.x;
    int ic = bid / blockPerN;
    int i = bid % blockPerN * blockDim.x + threadIdx.x;
    int *idx1 = d_elec+Cbase+ic;
    int *idx2 = d_elec+Cbase+ic+Nelec;
    int *idx3 = d_elec+Cbase+ic+Nelec*2;
    int *idx4 = d_elec+Cbase+ic+Nelec*3;
    float* e1 = d_e0+N*(*idx1-1);
    float* e2 = d_e0+N*(*idx2-1);
    float* e3 = d_e0+N*(*idx3-1);
    float* e4 = d_e0+N*(*idx4-1);
    float eA = e1[i]-e2[i];
    float eB = e3[i]-e4[i];
    eA = abs(eA);
    eB = abs(eB);
    // loop for 21 times
    float cuA,cuB,r0;
    for (int j = 0; j<Ncu;j++){
        cuA = cuConst[j];
        cuB = 2-cuA;
        float ax = cuA*eA;
        float bx = cuB*eB;
        if(alpha==1) r0 = 2*min(ax,bx);
        else r0 = powf(2*min(ax,bx),(float)alpha);
        rShare[tid] = r0*d_volume[i];
        //Parallel Reduction for max
        __syncthreads();
        for(int stride = (blockDim.x/2); stride > 32 ; stride /=2){ 
            if(tid < stride){
                rShare[tid] = fmaxf(rShare[tid],rShare[tid + stride]);
                __syncthreads();
            }
        }
        if(tid < 32) warpReduceMax(rShare,tid);
        if(tid == 0) r[bid+blockPerN*Ki*j] = rShare[0]; 
    }
}
