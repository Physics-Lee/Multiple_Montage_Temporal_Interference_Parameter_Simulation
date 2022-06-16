for i = 1:10    
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i);
    TIPSconfig(dataRoot,subMark,simMark);
end