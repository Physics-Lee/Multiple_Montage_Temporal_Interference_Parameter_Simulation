for ranking_number_of_subject = 2:26
    % unload cfg
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(ranking_number_of_subject);
    directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
    [cfg,~] = upload_cfg_and_elec4(directory);
    
    % OpenTIPS
    montage_number_threshold = 2*10^5;
    OpenTIPS(cfg,montage_number_threshold);
    OpenTIPS(cfg,montage_number_threshold);
end