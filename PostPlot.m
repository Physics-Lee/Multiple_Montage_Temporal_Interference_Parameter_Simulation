% this script is used to plot

%% Load optimized montage
i = 27;
[dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i); % set [dataRoot,subMark,simMark] for different subjects
directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
[cfg,elec4] = upload_cfg_and_elec4(directory_of_cfg);
Um = T2U(elec4.T(1,:));
%% electrode map
h1 = plotElec1010(Um,elec4.electrodes,0);
%% plot clip figure in X,Y,Z
Elf_Ub = 0.2;
m2mPath = fullfile(dataRoot,subMark, ['m2m_' subMark]);
ROI_center_sub = mni2subject_coords(cfg.ROI.table.CoordMNI, m2mPath);
clipStr = coordSub2clipStr(ROI_center_sub); % define clipStr from ROI center
disp(clipStr);
regionPlotMode = 2;% sphere ROI & Avoid region plot 
h2 = plotClip(cfg,Um,Elf_Ub,clipStr,regionPlotMode,ROI_center_sub,[]);