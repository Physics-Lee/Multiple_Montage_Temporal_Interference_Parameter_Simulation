function cuMutPool = CurrentMutMulti(cuSum)
posNum = 1:3;
x = cell(length(cuSum),length(posNum));
for i = 1:length(cuSum)
    for j = 1:length(posNum)
        if cuSum(i)>=posNum(j)
            if posNum(j) == 1
                x{i,j} = cuSum(i);
            else
                x{i,j} = PosIntSumCmb(cuSum(i),posNum(j));
            end
        else
            x{i,j} = zeros(0,4);
        end
    end
end
%%
y = cell(length(cuSum),length(posNum));
for i = 1:length(cuSum)
    for j = 1:length(posNum)
        n = size(x{i,j},1);
        if cuSum(i)>=posNum(j)
            switch posNum(j)
                case 1
                    y{i,j} = [x{i,j},-x{i,j},zeros(n,2)];
                case 2
                    tmp1PairIdx = [reshape(repmat(1:n,n,1),[],1),repmat(1:n,1,n)'];
                    tmp1 = [x{i,j}(tmp1PairIdx(:,1),:),-x{i,j}(tmp1PairIdx(:,2),:)];
                    tmp2 = [x{i,j},zeros(n,1),-repmat(cuSum(i),n,1)];
                    y{i,j} = [tmp1;tmp2;-tmp2];
                case 3
                    tmp1 = [x{i,j},-repmat(cuSum(i),n,1)];
                    y{i,j} = [tmp1;-tmp1];
            end
        end
    end
end
%% assemble
cuMutPool = cell(length(cuSum),1);
for i = 1:length(cuSum)
    tmp = cat(1,y{i,:});
    cuMutPool{i} = unique(tmp,'rows');
end
