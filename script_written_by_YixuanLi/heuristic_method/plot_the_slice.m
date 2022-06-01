%% load cfg.mat and load elec4.mat
i = 9;
[dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i); % set [dataRoot,subMark,simMark] for different subjects
directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
[cfg,elec4] = upload_cfg_and_elec4(directory);

%% electrode map

U_1 = T2U(elec4.T(1,:));
% plotElec1010(U_1,elec4.electrodes,0);

U_17 = T2U(elec4.T(17,:));
% plotElec1010(U_17,elec4.electrodes,0);

%% plot clip figure in X,Y,Z

Elf_Ub = 0.2;
m2mPath = fullfile(dataRoot,subMark, ['m2m_' subMark]);
ROI_center_sub = mni2subject_coords(cfg.ROI.table.CoordMNI, m2mPath);
clipStr = coordSub2clipStr(ROI_center_sub); % define clipStr from ROI center
disp(clipStr);
regionPlotMode = 2;% sphere ROI & Avoid region plot 

plotClip(cfg,U_1,Elf_Ub,clipStr,regionPlotMode,ROI_center_sub,[]);
plotClip(cfg,U_17,Elf_Ub,clipStr,regionPlotMode,ROI_center_sub,[]);