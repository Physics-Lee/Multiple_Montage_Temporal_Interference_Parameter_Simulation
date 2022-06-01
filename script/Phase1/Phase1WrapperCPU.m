function [T1,A_ROI,time_t] = Phase1WrapperCPU(input,c0,cu,thres)
N = int32(input.N);
E0 = input.E;
volume = input.volume;
cu = single(cu);
%% Transfer alpha from Inf to -1 to GPU input
if isinf(input.alpha)
    alpha = int32(-1);
else
    alpha = int32(input.alpha);
end
%% C0
C0 = int32(zeros(size(c0,1)*3,size(c0,2)));
c_seq = [1,2,3,4;1,3,2,4;1,4,2,3];
Nc0 = size(c0,1);
for i = 1:3
    idx = ((i-1)*Nc0+1):i*Nc0;
    C0(idx,:) = c0(:,c_seq(i,:));
end
Nelec = Nc0*3;
Ncu = length(cu);
%%
A_ROI = single(zeros(Ncu,Nelec));
tc = tic;
for i = 1:Nelec
    A_ROI(:,i) = ROI_Basic_CPU(E0,C0(i,:),cu,alpha,volume,thres);
end
time_t = toc(tc);
disp(['Phase 1 : CPU calculation in takes time : ' num2str(time_t) ' s...']);
T1 = Phase1Screen(A_ROI,C0,cu,thres);
