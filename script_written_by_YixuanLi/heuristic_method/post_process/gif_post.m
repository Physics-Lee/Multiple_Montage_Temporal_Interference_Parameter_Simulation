% upload cfg and elec4
clc;clear;close all;
subject_range = 9;
[dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(subject_range); % set [dataRoot,subMark,simMark] for different subjects
directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
[cfg,elec4] = upload_cfg_and_elec4(directory_of_cfg);

% upload montage_coupled
load(fullfile(directory_of_cfg,'montage_coupled.mat'),'montage_coupled'); % input montage_coupled
montage_chosen = montage_coupled(:,2); % input montage_coupled

% E max in the coloe bar
E_max_in_the_color_bar = 0.3;

% ROI center in subject coordinates
m2mPath = fullfile(dataRoot,subMark, ['m2m_' subMark]);
ROI_center_subject_coordinate = mni2subject_coords(cfg.ROI.table.CoordMNI, m2mPath);

% input
[input.E,input.volume,~,mesh] = temp_prepare_LF(dataRoot,subMark,cfg); % input E & volume & mesh & N by prepare_LF
input.N = size(input.E,1);

% calculate Elf_average
Elf_temp = zeros(input.N,length(montage_chosen)); % 预先分配空间以提高速度
for j = 1:length(montage_chosen)
    Elf_temp(:,j) = input_Elf(input,elec4,montage_chosen(j)); % Elf_temp的每一列是之前某个montage的ELf
end
Elf_average = mean(Elf_temp,2); % 对Elf_temp按行求平均

% slice
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
    h = plot_slice_for_average_Elf(cfg,Elf_average,E_max_in_the_color_bar,clipStr,2,ROI_center_subject_coordinate,[],direction_xyz);
    
    % gif
    frame = getframe(h); % important
    image{count}=frame2im(frame); % important
    count = count + 1;
    
end

switch direction_xyz
    case 1
        filename = ['post_' 'x' '.gif'];
    case 2
        filename = ['post_' 'y' '.gif'];
    case 3
        filename = ['post_' 'z' '.gif'];
end

for i = 1:length(slice_region)
    [A,map] = rgb2ind(image{i},256);
    if i == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
end