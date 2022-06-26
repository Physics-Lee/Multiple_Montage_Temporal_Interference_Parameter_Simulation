% upload cfg and elec4
clc;clear;close all;
subject_range = 1:10;
Elf_1_ROI_max = zeros(length(subject_range),1);
Elf_average_ROI_max = zeros(length(subject_range),1);

for i = subject_range
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i); % set [dataRoot,subMark,simMark] for different subjects
    directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
    [cfg,elec4] = upload_cfg_and_elec4(directory_of_cfg);
    
    % upload montage_coupled
    load(fullfile(directory_of_cfg,'montage_coupled.mat'),'montage_coupled'); % input montage_coupled
    montage_chosen = montage_coupled(:,2); % input montage_coupled
    
    % input
    [input.E,input.volume,~,mesh] = temp_prepare_LF(dataRoot,subMark,cfg); % input E & volume & mesh & N by prepare_LF
    input.N = size(input.E,1);
    
    % get Elf_1
    Elf_1 = input_Elf(input,elec4,montage_chosen(1));
    
    % get Elf_average
    Elf_temp = zeros(input.N,length(montage_chosen)); % 预先分配空间以提高速度
    for j = 1:length(montage_chosen)
        Elf_temp(:,j) = input_Elf(input,elec4,montage_chosen(j)); % Elf_temp的每一列是之前某个montage的ELf
    end
    Elf_average = mean(Elf_temp,2); % 对Elf_temp按行求平均
    
    % upload ROI_idx by TargetRegionIdx
    ROI_idx = TargetRegionIdx(dataRoot,subMark,mesh,cfg.ROI,cfg.type);
    
    % get max in ROI
    Elf_1_ROI = Elf_1(ROI_idx);
    Elf_1_ROI_max(i,1) = max(Elf_1_ROI);
    Elf_average_ROI = Elf_average(ROI_idx);
    Elf_average_ROI_max(i,1) = max(Elf_average_ROI);
    
end

ratio = Elf_average_ROI_max./Elf_1_ROI_max;