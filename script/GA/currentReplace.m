function currentReplaceList = currentReplace(cu0,n)
%CURRENTREPLACE Summary of this function goes here
%   Detailed explanation goes here
N = length(cu0);
currentReplaceList = single(zeros(N,n));
for i = 1:N
    currentTemplate = setdiff(cu0,cu0(i));
    currentDistance = abs(currentTemplate-cu0(i));
%     currentReplaceProbability = max(currentDistance)-currentDistance + mean(currentDistance);
    currentReplaceProbability = ones(1,(N-1));
    currentReplaceList(i,:) = randsample(currentTemplate,n,true,currentReplaceProbability);
end
end

