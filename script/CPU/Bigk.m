function [T1,U1] = Bigk(T,U,k)
%BIGK6 Summary of this function goes here
%   Detailed explanation goes here
sizeT = cellfun(@(x) size(x,1),T);
f6 = cell(size(T,1),1);
for i = 1:size(T,1)
    f6{i} = [repmat(i,sizeT(i),1),(1:sizeT(i))'];
end
Tall = vertcat(T{:});
fall = vertcat(f6{:});
[Ts,is] = sortrows(Tall,1,'d');
if k>size(Ts,1)
    k = size(Ts,1);
    warning('not enough new montage');
end
T1 = Ts(1:k,:);
label = fall(is(1:k),:);
U1 = cell(k,1);
for i = 1:k
    U1{i} = U{label(i,1)}{label(i,2)};
end
end

