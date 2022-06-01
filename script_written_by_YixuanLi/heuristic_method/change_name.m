for i = 1:26
    if i == 11
        continue;
    end
    
    set_dataRoot_subMark_simMark(i);
   
    directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
    try
        load(fullfile(directory,'T1_100000.mat')); % upload cfg.mat
        save(fullfile(directory,'T1_100000_0.20.mat'),'T1');
        delete(fullfile(directory,'T1_100000.mat'));
    catch
    end
    
end