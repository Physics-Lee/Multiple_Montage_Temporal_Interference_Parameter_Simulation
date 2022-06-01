for i = 1:26
    
    % jump 11
    if i == 11
        continue;
    end
    
    % dataRoot
    dataRoot = 'F:\simnibs_examples';
    
    % subMark
    switch i
        case 24
            subMark = 'CYJ';
        case 25
            subMark = 'RJC';
        case 26
            subMark = 'ernie';
        otherwise
            if i <= 9
                subMark = ['00' int2str(i)];
            elseif i >= 10 && i <= 23
                subMark = ['0' int2str(i)];
            end
    end
    
    % simMark
    simMark = 'NAc';
    
    % main process
    directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
    load(fullfile(directory,'montage_coupled.mat'));
    save(['E:\montage_coupled_' num2str(i) '.mat' ],'montage_coupled');
    
end