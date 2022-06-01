function [T,yMax,yMean] = GA_elec4(inputROI,inputOther,T1,otherAlpha,thres,elecPoolNum)
%GA_ELEC4 Summary of this function goes here
%% GA parameter setting
poolNum = size(T1,1);
GAopt.initialPopuNum = 20000;
GAopt.eliteNum = 50;
GAopt.ParentNum = 500;
GAopt.mutPercent = 1;
GAopt.crossPercent = 1;
GAopt.mutProbability = 0.45;
GAopt.loopNum = 20;
mutNum = round((GAopt.initialPopuNum - GAopt.eliteNum)*GAopt.mutPercent);
elecMutStoreNum = 10000;
[elecReplaceProbability,elecTemplate] = elecMutPro;
elecReplaceList = elecReplace(elecReplaceProbability,elecTemplate,elecMutStoreNum);
elecRelplaceListIdx = ones(elecPoolNum,1);
current = single(0.5:0.05:1.5);
loop = 0;
U4 = T2U(T1(randperm(poolNum,GAopt.initialPopuNum),:));
yMax = zeros(GAopt.loopNum,1);
yMean = zeros(GAopt.loopNum,1);
while loop<GAopt.loopNum
    loop = loop+1;
    disp(['GA loop ' num2str(loop) ' :']);
    disp('ROI step:');
    A_ROI = Phase2Wrapper(inputROI,U4,thres);
    disp('Other region step:');
    A_Other = Phase2Wrapper(inputOther,U4,thres);
    T = SortObject(U4,A_ROI,A_Other,otherAlpha,thres);
    disp(T(1:10,:));
    yMax(loop) = T.Ratio(1);
    yMean(loop) = mean(T.Ratio(1:50));
    T_elite = T(1:GAopt.eliteNum,:);% elite
    T_parent = T(1:GAopt.ParentNum,:);%
    Ratio_parent_rel = T_parent{:,1} - T{GAopt.ParentNum+1,1};
    w = Ratio_parent_rel./sum(Ratio_parent_rel);
    %% M_mut
    mutM_idx = randsample(GAopt.ParentNum,mutNum,true,w);
    mut_elec_pos = rand(mutNum,4)<GAopt.mutProbability;
    T_mut = T_parent(mutM_idx,:);
    %% elec mutation
    elec = [T_mut.elecA,T_mut.elecB];
    elecReplaceIdx = rand(size(elec)) < GAopt.mutProbability;
    elecRaw = elec(elecReplaceIdx);
    elecNew = elecRaw;
    for i = 1:length(elecRaw)
        elecNew(i) = elecReplaceList(elecRaw(i),elecRelplaceListIdx(elecRaw(i)));
        elecRelplaceListIdx(elecRaw(i)) = elecRelplaceListIdx(elecRaw(i))+1;
        if elecRelplaceListIdx(elecRaw(i)) == elecMutStoreNum
            elecRelplaceListIdx(elecRaw(i)) = 1;
        end
    end
    elec(elecReplaceIdx) = elecNew;
    T_mut.elecA = elec(:,1:2);
    T_mut.elecB = elec(:,3:4);
    %% cu mutation
    cu8 = randsample(current,mutNum,true,ones(1,length(current)))';
    T_mut.cuA = [cu8,-cu8];
    T_mut.cuB = [2-cu8,-2+cu8];
    %% assemble
    T_unformat = [T_elite;T_mut];
    T_mut = FormatT(T_unformat);
    U4 = T2U(T_mut);
end
T = T_mut;
end

