% 计算A_ROI的代码在这个函数里！！！

function [A_ROI,C0,time_t] = Phase1Wrapper(input,c0,cu,thres) % 输入：input是一个结构体，c0是n*4的电极位置，cu是电流的取值范围，thres是E_threshold
%%
N = int32(input.N);
E0 = input.E;
volume = input.volume;
cu = single(cu);
thres = single(thres);
%% Transfer alpha from Inf to -1 to GPU input
if isinf(input.alpha)
    alpha = int32(-1);
else
    alpha = int32(input.alpha);
end
%% C0
C0 = int32(zeros(size(c0,1)*3,size(c0,2)));
c_seq = [1,2,3,4;1,3,2,4;1,4,2,3];
Nc = size(c0,1);
for i = 1:3
    idx = ((i-1)*Nc+1):i*Nc;
    C0(idx,:) = c0(:,c_seq(i,:));
end
%% Kc : could be user defined
blockSize = int32(64);
Kc = getKcROI(size(E0,1),length(cu),size(C0,1),blockSize);
%% vflag
vflag = true;
%% GPU process
gpuDevice(1);
tg = tic;
if length(size(E0))==2
    disp('Using prefered electric orientation...');
    a = ROIPhaseNt(N,E0,C0,cu,volume,thres,alpha,Kc,vflag,blockSize); 
elseif length(size(E0))==3
    disp('Not using prefered electric orientation...');
    a = ROIPhase(N,E0,C0,cu,volume,thres,alpha,Kc,vflag,blockSize); 
end
if alpha > 0
    a = a.^(1/double(alpha));
end
time_t = toc(tg);
disp(['Phase 1 : GPU calculation in takes time : ' num2str(time_t) ' s...']);
A_ROI = reshape(a,size(C0,1),[])';