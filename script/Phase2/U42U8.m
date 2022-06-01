function U8 = U42U8(U4,elecNum)
%U42U8 Summary of this function goes here
%   Detailed explanation goes here
N = U4.num;
U8.num = N;
U8.a.elecNum = 4;
U8.b.elecNum = 4;
U8.a.elec = int32(zeros(N,U8.a.elecNum));
U8.b.elec = int32(zeros(N,U8.a.elecNum));
U8.a.cu = single(zeros(N,U8.a.elecNum));
U8.b.cu = single(zeros(N,U8.a.elecNum));
U8.a.elec(:,1:2) = U4.a.elec;
U8.b.elec(:,1:2) = U4.b.elec;
elec = [U4.a.elec,U4.b.elec];
elec_remain = int32(zeros(N,4));
idxPool = nchoosek(1:76-4,4);
idx = randi([1 size(idxPool,1)],N,1);
for i = 1:N
    pool = setdiff(1:76,elec(i,:));
    elec_remain(i,:) = pool(idxPool(idx(i),:));
end
U8.a.elec(:,3:4) = elec_remain(:,1:2);
U8.b.elec(:,3:4) = elec_remain(:,3:4);
U8.a.cu(:,1:2) = U4.a.cu;
U8.b.cu(:,1:2) = U4.b.cu;
[~,idxA] = sort(rand(N,U8.a.elecNum),2);
[~,idxB] = sort(rand(N,U8.a.elecNum),2);
for i = 1:N
    U8.a.elec(i,:) = U8.a.elec(i,idxA(i,:));
    U8.a.cu(i,:) = U8.a.cu(i,idxA(i,:));
    U8.b.elec(i,:) = U8.b.elec(i,idxB(i,:));
    U8.b.cu(i,:) = U8.b.cu(i,idxB(i,:));
end
end

