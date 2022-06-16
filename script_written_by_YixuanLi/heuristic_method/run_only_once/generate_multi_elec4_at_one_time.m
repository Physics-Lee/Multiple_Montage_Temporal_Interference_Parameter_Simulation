for i = 1:10    
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i);
    directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
    load(fullfile(directory_of_cfg,'cfg.mat'),'cfg');
    montage_number_threshold = 2*10^5;
    OpenTIPS(cfg,montage_number_threshold);
end