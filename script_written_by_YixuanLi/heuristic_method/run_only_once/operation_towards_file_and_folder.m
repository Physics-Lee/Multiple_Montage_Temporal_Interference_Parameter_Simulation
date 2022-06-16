for i = 1:1    
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i);
    cfg_directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
    rmdir(cfg_directory,'s');
end