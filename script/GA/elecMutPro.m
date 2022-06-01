function [p,elecTemplate] = elecMutPro
%ELECDISTANCE Summary of this function goes here
%   Detailed explanation goes here
T = elecNeighborTable;
N = size(T,1);
distanceM = zeros(N,N);
for i = 1:N
    pool1 = i;
    pool2 = i;
    d = 1;
    while length(pool1)<N
        pool2 = setdiff(unique(cat(1,T.neighbourIdx{pool2})),pool1);
        distanceM(i,pool2) = d;
        d = d+1;   
        pool1 = [pool1;pool2];
    end
end
%%
p = zeros(N,N-1);
elecTemplate = int32(zeros(N,N-1));
elecPool = int32(1:76);
for i = 1:N
    idx = distanceM(i,:)==0;
    elecTemplate(i,:) = elecPool(~idx);
    tmp = distanceM(i,~idx);
    p(i,:) = max(tmp)-tmp+1+mean(tmp);
end

