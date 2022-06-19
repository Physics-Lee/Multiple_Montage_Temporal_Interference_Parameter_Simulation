% this function is used to create cfg.mat

function cfg = TIPSconfig(dataRoot,subMark,simMark)
%% path
cfg.dataRoot = dataRoot;
cfg.subMark = subMark;
cfg.simMark = simMark;
cfg.elecNum = 4;
cfg.optimalMethod = 'Exhaustion';
cfg.type = 'tet';
cfg.thres = 0.2; % unit V/m
cfg.nt = 0;
%% table
varTypes = ["string","double","double","string","double"];
varNames = ["Name","CoordMNI","CoordSub","Shape","Radius"];
length(varNames);
%% ROI
cfg.ROI.num = 1;
cfg.ROI.table = table('Size',[cfg.ROI.num,length(varNames)],'VariableTypes',varTypes,'VariableNames',varNames);
cfg.ROI.table.Name = "NAc";
cfg.ROI.table.Shape = "Sphere";
cfg.ROI.table.CoordMNI = [-12 8 -8];
directory_of_subject2mni_coords = [fullfile(dataRoot,subMark) '\m2m_' subMark '/'];
cfg.ROI.table.CoordSub = mni2subject_coords(cfg.ROI.table.CoordMNI,directory_of_subject2mni_coords, 'nonl');
cfg.ROI.table.Radius = 5;
cfg.ROI.alpha = 2;
%% Avoid
cfg.Avoid.num = 0;
cfg.Avoid.table = table('Size',[cfg.Avoid.num,length(varNames)],'VariableTypes',varTypes,'VariableNames',varNames);
cfg.Avoid.coef = 2;
%% other coefficients
cfg.Other.alpha = 2;
%% save
directory_of_cfg = fullfile(cfg.dataRoot,cfg.subMark,'TI_sim_result',cfg.simMark);
if ~exist(directory_of_cfg,'dir')
    mkdir(directory_of_cfg);
end
save(fullfile(directory_of_cfg,'cfg.mat'),'cfg');