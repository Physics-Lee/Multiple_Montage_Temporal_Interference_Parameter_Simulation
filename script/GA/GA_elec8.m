function [T,yMax,yMean] = GA_elec8(inputROI,inputOther,T1,otherAlpha,thres,elecPoolNum)
%GA_ELEC8 Summary of this function goes here
%% GA parameter setting
GAopt.loopNum = 20;
GAopt.initialPopuNum = 40000;
GAopt.eliteNum = 50;
GAopt.ParentNum = 1000;
GAopt.mutPercent = 0.8;
GAopt.crossPercent = 0.2;
GAopt.mutProbability = 0.45;
mutNum = round((GAopt.initialPopuNum - GAopt.eliteNum)*GAopt.mutPercent);
crossNum = round((GAopt.initialPopuNum - mutNum)/2)*2;
elecMutStoreNum = 20000;
[elecReplaceProbability,elecTemplate] = elecMutPro;
elecReplaceList = elecReplace(elecReplaceProbability,elecTemplate,elecMutStoreNum);
elecRelplaceListIdx = ones(elecPoolNum,1);
cuMutRange = -5:5;
loop = 0;
cuPool = CurrentElec8;
yMax = zeros(GAopt.loopNum,1);
yMean = zeros(GAopt.loopNum,1);
%% initial U from electrode 4 result
initialPopuNum = min(size(T1,1),GAopt.initialPopuNum);
U4 = T2U(T1(1:initialPopuNum,:));
U8 = U42U8(U4,elecPoolNum);
%% begin loop
while loop < GAopt.loopNum
    loop = loop+1;
    disp(['GA loop ' num2str(loop) ' :']);
    disp('ROI step:');
    A_ROI = Phase2Wrapper(inputROI,U8,thres);%
    disp('Other region step:');
    A_Other = Phase2Wrapper(inputOther,U8,thres);%
    T = SortObject(U8,A_ROI,A_Other,otherAlpha,thres);
    disp(T(1:10,:));
    yMax(loop) = T.Ratio(1);
    yMean(loop) = mean(T.Ratio(1:50));
    %% elite
    T_elite = T(1:GAopt.eliteNum,:);% elite
    %% parent
    parentNum = min(size(T,1)-1,GAopt.ParentNum);
    T_parent = T(1:parentNum,:);%
    %     Ratio_parent_rel = abs(T_parent{:,1} - T{parentNum+1,1});
    %     w = Ratio_parent_rel./sum(Ratio_parent_rel);
    w = ones(parentNum,1)./parentNum;
    %% mutation
    mutM_idx = randsample(parentNum,mutNum,true,w);
    T_mut = T_parent(mutM_idx,:);
    %% elec mutation
    elec_mut = [T_mut.elecA,T_mut.elecB];
    elecReplaceIdx = rand(size(elec_mut)) < GAopt.mutProbability;
    elecRaw = elec_mut(elecReplaceIdx);
    elecNew = elecRaw;
    for i = 1:length(elecRaw)
        elecNew(i) = elecReplaceList(elecRaw(i),elecRelplaceListIdx(elecRaw(i)));
        elecRelplaceListIdx(elecRaw(i)) = elecRelplaceListIdx(elecRaw(i))+1;
        if elecRelplaceListIdx(elecRaw(i)) == elecMutStoreNum
            elecRelplaceListIdx(elecRaw(i)) = 1;
        end
    end
    elec_mut(elecReplaceIdx) = elecNew;
    %% cu mutation
    tmp = int32(T_mut.cuA./0.05);
    tmp(tmp<0)=0;
    cuSumA = sum(tmp,2);
    cuSumA = cuSumA + cuMutRange(randi(length(cuMutRange),mutNum,1))';
    cuSumA(cuSumA<10) = 15;
    cuSumA(cuSumA>30) = 30;
    cuSumB = 40 - cuSumA;
    cuType = 10:30;
    cuTypeNum = length(cuType);
    for i = 1:cuTypeNum
        idx = cuSumA==cuType(i);
        T_mut.cuA(idx,:) = single(0.05*cuPool{i}(randi([1,size(cuPool{i},1)],sum(idx),1),:));
        idx = cuSumB==cuType(i);
        T_mut.cuB(idx,:) = single(0.05*cuPool{i}(randi([1,size(cuPool{i},1)],sum(idx),1),:));
    end
    %%
    T_crossNum = T_parent(randsample(parentNum,crossNum,true,ones(parentNum,1)/parentNum),:);
    halfNum = crossNum/2;
    crossPoint = randi([2,7],halfNum,1);
    for i = 1:halfNum
        if crossPoint(i)<=4
            tmp_idx = crossPoint(i):4;
            tmp = T_crossNum.elecA(i,tmp_idx);
            T_crossNum.elecA(i,tmp_idx) = T_crossNum.elecA(i+halfNum,tmp_idx);
            T_crossNum.elecA(i+halfNum,tmp_idx) = tmp;
            tmp = T_crossNum.elecB(i,:);
            T_crossNum.elecB(i,:) = T_crossNum.elecB(i+halfNum,:);
            T_crossNum.elecB(i+halfNum,:) = tmp;
        else
            tmp_idx = crossPoint(i)-4:4;
            tmp = T_crossNum.elecB(i,tmp_idx);
            T_crossNum.elecB(i,tmp_idx) = T_crossNum.elecB(i+halfNum,tmp_idx);
            T_crossNum.elecB(i+halfNum,tmp_idx) = tmp;
        end
    end
    disp(['cross number is ' num2str(size(T_crossNum,1)) ' .']);
    %% format
    T_unformat = [T_elite;T_mut;T_crossNum];
    T_mut = FormatT(T_unformat);
    U8 = T2U(T_mut);
    disp([num2str((T.Ratio(1)/T1.Ratio(1)-1)*100) ' % improvement.'])
end
T = T_mut;
end

