dataRoot = 'I:\Stroop_GLM';
d = dir(fullfile(dataRoot, '0*'));
cfg.type = 'tet';
cfg.nt = false;
ME = cell(length(d),1);
for i = 1:length(d)
    subMark = d(i).name;
    disp(subMark);
    try
        SIMNIBS_headreco(dataRoot,subMark);
%         SIMNIBS_LF_tet(dataRoot,subMark);
        prepare_LF(dataRoot,subMark,cfg);
    catch ME0
        ME{i} = ME0;
    end
end

