% upload cfg and elec4
clc;clear;close all;
subject_number = 9;
[dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(subject_number); % set [dataRoot,subMark,simMark] for different subjects
directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
[cfg,elec4] = upload_cfg_and_elec4(directory_of_cfg);

% plot the first montage
U = T2U(elec4.T(1,:));

% E max in the coloe bar
E_max_in_the_color_bar = 0.3;

% ROI center in subject coordinates
m2mPath = fullfile(dataRoot,subMark, ['m2m_' subMark]);
ROI_center_subject_coordinate = mni2subject_coords(cfg.ROI.table.CoordMNI, m2mPath);

direction_xyz = 3; % 1 for x, 2 for y, 3 for z.
slice_region = 30:2:38;
count = 1;
image = cell(1,length(slice_region));

for i = slice_region % x_region = [-60 +60], y_region = [-70 +100], z_region = [-70 +70].
    
    switch direction_xyz
        case 1
            clipStr = coordSub2clipStr([i ROI_center_subject_coordinate(2) ROI_center_subject_coordinate(3)]);
        case 2
            clipStr = coordSub2clipStr([ROI_center_subject_coordinate(1) i ROI_center_subject_coordinate(3)]);
        case 3
            clipStr = coordSub2clipStr([ROI_center_subject_coordinate(1) ROI_center_subject_coordinate(2) i]);
    end

    % plot slice
    h = plot_slice_to_make_gif(cfg,U,E_max_in_the_color_bar,clipStr,2,ROI_center_subject_coordinate,[],direction_xyz);
    
    % gif
    frame = getframe(h); % important
    image{count}=frame2im(frame); % important
    count = count + 1;
    
end

switch direction_xyz
    case 1
        filename = ['pre_' 'x' '.gif'];
    case 2
        filename = ['pre_' 'y' '.gif'];
    case 3
        filename = ['pre_' 'z' '.gif'];
end

for i = 1:length(slice_region)
    [A,map] = rgb2ind(image{i},256);
    if i == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
end