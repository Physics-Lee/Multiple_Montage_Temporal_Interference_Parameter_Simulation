for i = [5 10 11 15 18 22]
    set_dataRoot_subMark_simMark(i);
    directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
    load(fullfile(directory,'cfg.mat')); 
    OpenTIPS(cfg,10^5);
    OpenTIPS(cfg,10^5);
end