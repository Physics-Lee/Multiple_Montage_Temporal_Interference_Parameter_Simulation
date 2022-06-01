function [A,time_t] = Phase2Wrapper(input,U,thres)
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
vflag = true;
%%
blockSize = int32(128);
parallelNum = getKcPhase2(N,U.num);
%% GPU process
gpuDevice(1);
t0 = tic;
if length(size(E0))==3
    A = MultiElec(N,E0,U.a.elec,U.b.elec,U.a.cu,U.b.cu,volume,thres,alpha,parallelNum,vflag,blockSize);
elseif length(size(E0))==2
    A = MultiElecNt(N,E0,U.a.elec,U.b.elec,U.a.cu,U.b.cu,volume,thres,alpha,parallelNum,vflag,blockSize);
end
if alpha>0
    A = A.^(1/double(alpha));
end
time_t = toc(t0);
disp(['GPU calculation takes time : ' num2str(time_t) ' s...']);
end