subject_range = 1;
for i = subject_range
    fprintf('i = %d\n',i);
    
    % upload cfg and elec4
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i); % set [dataRoot,subMark,simMark] for different subjects
    directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
    [cfg,elec4] = upload_cfg_and_elec4(directory_of_cfg);
    
    % upload montage_coupled
    load(fullfile(directory_of_cfg,'montage_coupled.mat'),'montage_coupled'); % input montage_coupled
    montage_chosen = montage_coupled(:,2); % input montage_coupled
    
    % main process
    for j = 1:length(montage_chosen) % or you can use 1:length(montage_chosen)
        
        %% get U
        fprintf('i = %d, j = %d, montage_rank = %d\n',i,j,montage_chosen(j));
        U = T2U(elec4.T(montage_chosen(j),:));
        
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
        
    end
    
    %% calculate Elf_average
    
    % input
    [input.E,input.volume,~,mesh] = temp_prepare_LF(dataRoot,subMark,cfg); % input E & volume & mesh & N by prepare_LF
    input.N = size(input.E,1);
    
    % calculate
    Elf_temp = zeros(input.N,length(montage_chosen)); % 预先分配空间以提高速度
    for j = 1:length(montage_chosen)
        fprintf('i = %d,j = %d\n',i,j);
        Elf_temp(:,j) = input_Elf(input,elec4,montage_chosen(j)); % Elf_temp的每一列是之前某个montage的ELf
    end
    
    Elf_average = mean(Elf_temp,2); % 对Elf_temp按行求平均
    
    %% plot slice for average Elf
    plot_slice_for_average_Elf(cfg,Elf_average,E_max_in_the_color_bar,clipStr,regionPlotMode,ROI_center_subject_coordinate,[]);
    
end