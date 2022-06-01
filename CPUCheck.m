% This script is used to ?

%% Check with CPU program
dataRoot = 'D:\simnibs_examples';
subMark = '015';
simMark = '202204071639_NAc_Radius1_InfDivide2_WithoutPenalty';
simDir = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
temp_cfg = load(fullfile(simDir,'cfg.mat'));
cfg = temp_cfg.cfg;
[inputROI,inputOther,electrodes] = prepare_LF(cfg); % prepare_LF
cu = (0.5+(0:20)*0.05)';
cmb = int32(nchoosek(1:size(electrodes,1),4));
thres = cfg.thres;

%%
inputROI.alpha = 2;
[A_ROI,cmb3] = Phase1Wrapper(inputROI,cmb,cu,thres); % Phase1Wrapper
T1 = Phase1Screen(A_ROI,cmb3,cu,thres,inputROI.alpha); % Phase1Screen
i = 1:10;
Ti = T1(i,:);
disp(Ti);
Ui = T2U(Ti);
[Di,~,Di0] = Onetime(inputROI,Ui,cfg.thres); % Onetime
disp(Di);