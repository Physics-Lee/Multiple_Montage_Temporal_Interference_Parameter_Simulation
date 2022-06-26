clc;clear;close all;
subject_number = 9;

% upload cfg and elec4
[dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(subject_number); % set [dataRoot,subMark,simMark] for different subjects
directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
[cfg,elec4] = upload_cfg_and_elec4(directory_of_cfg);

% plot the first montage
U = T2U(elec4.T(1,:));

% plot electrode map
plotElec1010(U,elec4.electrodes,0);

%% plot hot graph of slice

% E max in the coloe bar
E_max_in_the_color_bar = 0.3;

% ROI center in subject coordinates
m2mPath = fullfile(dataRoot,subMark, ['m2m_' subMark]);
ROI_center_subject_coordinate = mni2subject_coords(cfg.ROI.table.CoordMNI, m2mPath);
clipStr = coordSub2clipStr(ROI_center_subject_coordinate); % define clipStr from ROI center in subject coordinate

% mode
regionPlotMode = 2; % sphere ROI & Avoid region plot

% plot slice
plot_slice(cfg,U,E_max_in_the_color_bar,clipStr,regionPlotMode,ROI_center_subject_coordinate,[]);