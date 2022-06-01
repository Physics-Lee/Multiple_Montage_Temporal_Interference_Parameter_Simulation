
__global__ void getDot(int M, int N, float* in, float * out, float * A)
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i < M ){
        float tmp = 0;
        for(int ii = 0; ii<N; ii++){
            tmp += A[ii]*(*(in+N*i+ii));
        }
        out[i] = atmp;
    }
}
__global__ void getDot2(int M, int N, float* in, float * out, float * A)
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i < M ){
        float tmp = 0;
        float tmp1;
        for(int ii = 0; ii<N; ii++){
            tmp1 = *(in+N*i+ii);
            tmp += A[ii]*tmp1*tmp1;
        }
        out[i] = tmp;
    }
}
__global__ void Idx2Value(int M, int N,float *in, int* ri,float * out)                   
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i<M)
        out[i] = in[N*i+ri[i]-1];
}

__host__ void cublasMax(int M, int N, float* in, float *out)
{
    cublasHandle_t cublasHandle = 0;
    cublasStatus_t cublasStatus;
    cublasStatus = cublasCreate(&cublasHandle);
    const mwSize ndim = 1;
    mwSize dims[ndim];
    dims[0] = M;
    mxArray * Ri = mxCreateNumericArray(ndim, dims, mxINT32_CLASS, mxREAL);
    int *d_Ri = (int*)mxGetData(Ri);
    for (int j = 0; j < M; j++)
    {
        cublasStatus = cublasIsamax(cublasHandle,N,in+N*j,1,d_Ri+j);
        if (cublasStatus!= CUBLAS_STATUS_SUCCESS) mxShowCriticalErrorMessage("cublasIsamax failed");
    }  
    mxGPUArray const *ri = mxGPUCreateFromMxArray(Ri);
    int *d_ri = (int*)mxGPUGetDataReadOnly(ri); 
    int blockSize = 1024;
    int gridSize = (M + blockSize - 1) / blockSize;
    Idx2Value<<<blockSize, gridSize>>>(M,N,in,d_ri,out);
    mxDestroyArray(Ri);
    mxGPUDestroyGPUArray(ri);
    cublasDestroy(cublasHandle);
}
__host__ void cublasSum(int M, int N, float* in, float *out)
{
    cublasHandle_t cublasHandle = 0;
    cublasStatus_t cublasStatus;
    cudaError_t cudaStatus;
    cublasStatus = cublasCreate(&cublasHandle);
    const mwSize ndim = 1;
    mwSize dims[ndim];
    dims[0] = M;
    mxArray * Rf = mxCreateNumericArray(ndim, dims, mxSINGLE_CLASS, mxREAL);
    float *d_Rf = (float*)mxGetData(Rf);
    for (int j = 0;j<M;j++){
        cublasStatus = cublasSasum(cublasHandle, N, in+N*j, 1, d_Rf+j);
        if (cublasStatus!= CUBLAS_STATUS_SUCCESS) mxShowCriticalErrorMessage("cublasSasum failed");
    }
    cudaStatus = cudaMemcpy(out, d_Rf, sizeof(float) * M, cudaMemcpyHostToDevice);
    if (cudaStatus!= cudaSuccess) mxShowCriticalErrorMessage("cudaMemcpy in cublasSum failed");
    mxDestroyArray(Rf);
    cublasDestroy(cublasHandle);         
}
__host__ void cublasDot(int M, int N, float* in, float *out, float* area)
{
    cublasHandle_t cublasHandle = 0;
    cublasStatus_t cublasStatus;
    cudaError_t cudaStatus;
    cublasStatus = cublasCreate(&cublasHandle);
    const mwSize ndim = 1;
    mwSize dims[ndim];
    dims[0] = M;
    mxArray * Rf = mxCreateNumericArray(ndim, dims, mxSINGLE_CLASS, mxREAL);
    float *d_Rf = (float*)mxGetData(Rf);
    for (int j = 0;j<M;j++){
        cublasStatus = cublasSdot(cublasHandle,N, in+N*j, 1, area, 1, d_Rf+j);
        if (cublasStatus!= CUBLAS_STATUS_SUCCESS) mxShowCriticalErrorMessage("cublasSasum failed");
    }     
    cudaStatus = cudaMemcpy(out, d_Rf, sizeof(float) * M, cudaMemcpyHostToDevice);
    if (cudaStatus!= cudaSuccess) mxShowCriticalErrorMessage("cudaMemcpy in cublasSum failed");
    mxDestroyArray(Rf);
    cublasDestroy(cublasHandle);    
}