% this function is used to calculate the index of the target region

function [target_node_idx] = TargetRegionIdx(dataRoot,subMark,mesh,cfgTarget,cfgType)
    switch cfgType
        case 'tri'
            target_node_idx = TargetSurf(dataRoot,subMark,mesh,cfgTarget); % TargetSurf
        case 'tet'
            target_node_idx = TargetTet(dataRoot,subMark,mesh,cfgTarget); % TargetTet
    end
end

