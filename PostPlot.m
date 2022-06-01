% this script is used to plot

%% Load optimized montage
dataRoot = 'D:\simnibs_examples';
subMark = 'RJC';
simMark = '202204071545_NAc';
dir = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
load(fullfile(dir,'cfg.mat'));
resultDir = fullfile(cfg.dataRoot,cfg.subMark,'TI_sim_result',cfg.simMark);
S = load(fullfile(resultDir,'elec4_Genetic Algorithm.mat'));
Um = T2U(S.T(1,:));
%% electrode map
h1 = plotElec1010(Um,S.electrodes,0);
%% plot clip figure in X,Y,Z
Elf_Ub = 0.2;
m2mPath = fullfile(dataRoot,subMark, ['m2m_' subMark]);
ROI_center_sub = mni2subject_coords(cfg.ROI.table.CoordMNI, m2mPath);
clipStr = coordSub2clipStr(ROI_center_sub); % define clipStr from ROI center
disp(clipStr);
regionPlotMode = 2;% sphere ROI & Avoid region plot 
h2 = plotClip(cfg,Um,Elf_Ub,clipStr,regionPlotMode,ROI_center_sub,[]);