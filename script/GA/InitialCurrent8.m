function cuMontage = InitialCurrent8(N,cuPool)
%INITIALCU Summary of this function goes here
%   Detailed explanation goes here
cuType = 10:30;
cuTypeNum = length(cuType);
cuSumA = cuType(randi([1,cuTypeNum],N,1));
cuSumB = 40-cuSumA;
cuMontage = zeros(N,8);
for i = 1:cuTypeNum
    idx = cuSumA==cuType(i);
    cuMontage(idx,1:4) = cuPool{i}(randi([1,size(cuPool{i},1)],sum(idx),1),:);
    idx = cuSumB==cuType(i);
    cuMontage(idx,5:8) = cuPool{i}(randi([1,size(cuPool{i},1)],sum(idx),1),:);
end





