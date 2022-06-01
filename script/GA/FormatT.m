function M = FormatT(M)
%% sort per row
[M.elecA,ia] = sort(M.elecA,2,'a');
for i = 1:size(M,1)
    M.cuA(i,:) = M.cuA(i,ia(i,:));
end
[M.elecB,ib] = sort(M.elecB,2,'a');
for i = 1:size(M,1)
    M.cuB(i,:) = M.cuB(i,ib(i,:));
end
%% exchange AB
idx = M.elecA(:,1)>M.elecB(:,1);
tmp = M.elecA(idx,:);
M.elecA(idx,:) = M.elecB(idx,:);
M.elecB(idx,:) = tmp;
tmp = M.cuA(idx,:);
M.cuA(idx,:) = M.cuB(idx,:);
M.cuB(idx,:) = tmp;
%% 
idx = M.cuA(:,1)<0;
M.cuA(idx,:) = -M.cuA(idx,:);
idx = M.cuB(:,1)<0;
M.cuB(idx,:) = -M.cuB(idx,:);
%% elec repetition
elecNumAll = size(M.elecA,2)+size(M.elecB,2);
N = size(M,1);
elecSeq = [M.elecA,M.elecB];
uNum = zeros(N,1);
for i = 1:N
    uNum(i) = length(unique(elecSeq(i,:)));
end
idx = uNum < elecNumAll;
M(idx,:)=[];
disp(['Remove electrode repetition ' num2str(sum(idx)) ' montages.']);
%% montage repetition
montageSeq = [M.elecA,M.elecB,int32([M.cuA,M.cuB]./0.05)];
[~,iu] = unique(montageSeq,'rows','stable');
M = M(iu,:);
disp(['Remove montage repetition ' num2str(size(montageSeq,1)-length(iu)) ' montages.']);
disp(['There are ' num2str(length(iu)) ' candidate mongtage in this GA loop...']);
end

