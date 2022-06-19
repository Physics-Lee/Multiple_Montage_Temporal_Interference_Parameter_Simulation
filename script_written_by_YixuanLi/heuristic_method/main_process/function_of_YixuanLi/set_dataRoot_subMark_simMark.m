function [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i)

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
    case 27 
        subMark = 'LYX';
    otherwise
        if i <= 9
            subMark = ['00' int2str(i)];
        elseif i >= 10 && i <= 23
            subMark = ['0' int2str(i)];
        end
end

% simMark
simMark = 'ACC_20220618';

end