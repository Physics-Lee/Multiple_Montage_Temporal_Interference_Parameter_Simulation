subject_range = [1:26]; % 被试范围

for i = subject_range
    % jump 11
    if i == 11
        continue;
    end
    
    load(['F:\1_learning\1_theory_experiment_computation\TI+ISP\montage_coupled\montage_coupled_' num2str(i) '.mat']);
    
    montage_chosen = montage_coupled(:,2); % 最开始选哪个montage当seed
    
    % easy
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i); % set [dataRoot,subMark,simMark] for different subjects
    directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
    [cfg,elec4] = upload_cfg_and_elec4(directory); % input cfg.mat and elec4.mat
    [input.E,input.volume,~,mesh] = temp_prepare_LF(dataRoot,subMark,cfg); % input E & volume & mesh & N by prepare_LF
    input.N = size(input.E,1);
    ROI_idx = TargetRegionIdx(dataRoot,subMark,mesh,cfg.ROI,cfg.type); % input ROI_idx
    
    % calculate the average value of all the previous montages' Elf
    Elf_temp = zeros(length(ROI_idx),length(montage_chosen)); % 预先分配空间以提高速度
    for j = 1:length(montage_chosen)
        Elf_temp(:,j) = input_Elf(input,elec4,montage_chosen(j)); % Elf_temp的每一列是之前某个montage的ELf
    end
    Elf = mean(Elf_temp,2); % 对Elf_temp按行求平均
    Elf_Other = Elf(~ROI_idx); % Other中的El
    
    % histfit
    figure(i);
    histfit(Elf_Other,100,'beta');
    saveas(figure(i),[ num2str(i) '.png']);
    
    % fitdist
    beta_distribution = fitdist(Elf_Other,'beta');
    save(['E:\' 'beta_distribution_' num2str(i) '.mat'],'beta_distribution');
    
end