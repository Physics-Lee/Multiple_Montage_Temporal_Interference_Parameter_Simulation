dataRoot = 'C:\Users\psylab706\Documents\simnibs_examples';
% dataRoot = 'E:\MyLabFiles\TI_Simulation';
subMark = 'ernie';
simMark = 'test_tet_ACC_noPenalty_r5_mO2';
workSpace = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
S = load(fullfile(workSpace,'elec4.mat'));
load(fullfile(workSpace,'cfg.mat'));
%% load U
Eam_Ub = 0.2;
%% predefine clipStr
clipStr = clipStrFromCenter(dataRoot,subMark,cfg.ROI.center); % define clipStr from ROI center
% clipStr{1} = 'y=21'; % define clipStr directly in sub Space
disp(clipStr);
%% plot
h = plotClip(dataRoot,subMark,cfg,Um,Eam_Ub,clipStr);


