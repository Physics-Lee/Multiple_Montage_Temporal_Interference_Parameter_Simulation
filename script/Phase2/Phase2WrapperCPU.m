function A = Phase2WrapperCPU(input,U,thres)
%% N,beta,alpha
N = int32(input.N);
E0 = input.E;
volume = input.volume;
thres = single(thres);
%% Transfer alpha from Inf to -1 to GPU input
if isinf(input.alpha)
    alpha = int32(-1);
else
    alpha = int32(input.alpha);
end
%% CPU process
gpuDevice(1);
tg = tic;
if length(size(E0))==3
     A = MultiElec(N,E0,U.a.elec,U.b.elec,U.a.cu,U.b.cu,volume,thres,alpha,parallelNum,vflag,blockSize);
    if alpha>0
        A = A.^(1/double(alpha));
    end
elseif length(size(E0))==2
end
disp(['GPU calculation takes time : ' num2str(toc(tg)) ' s...']);
end

