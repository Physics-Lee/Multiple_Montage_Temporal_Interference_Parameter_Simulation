for i = 1:26    
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i);
    directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
    try
        load(fullfile(directory,'T1_100000.mat')); % upload cfg.mat
        delete(fullfile(directory,'T1_100000.mat'));
    catch
    end
end