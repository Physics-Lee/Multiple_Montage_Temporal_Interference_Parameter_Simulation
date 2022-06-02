function [T,montage_number_after_Phase_1] = OpenTIPS(cfg,montage_number_threshold)

%% pre process
% start time
start = datestr(now);

% easy
dataRoot = cfg.dataRoot;
subMark = cfg.subMark;
simMark = cfg.simMark;
thres = 0.15;
elecNum = cfg.elecNum;
optimalMethod = cfg.optimalMethod;
simDir = fullfile(dataRoot,subMark,'TI_sim_result',simMark);

% Check brain mesh
SIMNIBS_headreco(dataRoot,subMark); % first time running for building mesh

% Check output directory
if ~isfolder(simDir) % 若不存在这个文件夹，则创建该文件夹
    disp(['The new directory with simMark ' simMark ' creates.']); % 第一次运行时，创建该文件夹
    mkdir(simDir);
end

% Prepare leadfield
[inputROI,inputOther,electrodes] = prepare_LF(cfg);

%% main process
%% step 1: ROI screen
disp('Phase 1. Calculate the Elf of ROI for screen.');
if isfile([simDir '\T1_' num2str(montage_number_threshold) '.mat']) % 如果存在该文件夹
    load([simDir '\T1_' num2str(montage_number_threshold) '.mat'],'T1');
    montage_number_after_Phase_1 = montage_number_threshold;
else % 如果不存在该文件夹
    cu = (0.5+(0:20)*0.05)';
    cmb = int32(nchoosek(1:size(electrodes,1),4)); % 从76个整数里面选出4个
    [A_ROI,cmb3] = Phase1Wrapper(inputROI,cmb,cu,thres); % Phase1Wrapper
    T1 = Phase1Screen(A_ROI,cmb3,cu,thres,inputROI.alpha); % Phase1Screen
    cfg.Avoid.coef = 1;
    montage_number_after_Phase_1 = size(T1,1);
end
U4 = T2U(T1);
%% step 2: Other sort
switch optimalMethod
    case 'Exhaustion'
        disp('Phase 2. Calculate the Elf in Other brain region with screened parameters.');
        A_Other = Phase2Wrapper(inputOther,U4,thres); % Phase2Wrapper % A_Other is the Elf in Other
        T = SortObject(U4,T1.ROI,A_Other,cfg.Other.alpha,thres); % SortObject
end

%% post process 
% save elec4.mat
if ~isfile([simDir ['\T1_' num2str(montage_number_threshold) '.mat']]) % 若不存在该文件
    % 先存一下elec4
    saveFile = fullfile(simDir,['elec' num2str(cfg.elecNum) '_' optimalMethod '_T1_' num2str(size(T1,1)) '_PenaltyCoefficient_' num2str(cfg.Avoid.coef) '.mat']);
    save(saveFile,'optimalMethod','elecNum','T','electrodes');
    % 取出前montage_number_threshold个montage并保存
    elec = [T.elecA T.elecB];
    cu = T.cuA(:,1);
    ROI = T.ROI;
    elec = elec(1:montage_number_threshold,:);
    cu = cu(1:montage_number_threshold,:);
    ROI = ROI(1:montage_number_threshold,:);
    T1 = table(elec,cu,ROI);
    save(fullfile(dataRoot,subMark,'TI_sim_result',simMark,['T1_' num2str(montage_number_threshold) '.mat']),'T1');
    disp(['The top ' num2str(montage_number_threshold) ' montages have been saved, please run OpenTIPS again!!!']);
else % 若存在该文件
    saveFile = fullfile(simDir,['elec' num2str(cfg.elecNum) '_' optimalMethod '_T1_' num2str(montage_number_threshold) '_PenaltyCoefficient_' num2str(cfg.Avoid.coef) '.mat']);
    save(saveFile,'optimalMethod','elecNum','T','electrodes');
end

% end time
disp(['Start time : ' start]);
disp(['End time : ' datestr(now)]);

end