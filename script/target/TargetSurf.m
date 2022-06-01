function [target_node_idx_all] = TargetSurf(dataRoot,subMark,gmS,cfgTarget)
%% target_node_idx
m2mPath = fullfile(dataRoot,subMark, ['m2m_' subMark]);
disp(['Target region number is ' num2str(cfgTarget.num)]);
target_node_idx = false(size(gmS.nodes,1),cfgTarget.num);
switch cfgTarget.type
    case 'atlas'
        disp(['Define target using atlas ' cfgTarget.atlas '...']);
        [labels, snames] = subject_atlas(gmS, m2mPath, cfgTarget.atlas);
        for i = 1:cfgTarget.num
            target_label = find(strcmpi(snames, cfgTarget.name{i}));
            if isempty(target_label)
                error('No corresponding ROI name for this atlas!');
            else
                target_node_idx(:,i) = labels.node_data{1}.data == target_label;
            end
        end
    case 'coord'
        disp('Define target using MNI coordinates ... ');
        coord_sub = mni2subject_coords(cfgTarget.center, m2mPath);%MNI to subject space
        for i = 1:cfgTarget.num   
            target_node_idx(:,i) = vecnorm(gmS.nodes-coord_sub(i,:),2,2)<cfgTarget.r(i);
        end
    otherwise
        error('Wrong target type!');
end
target_node_idx_all = any(target_node_idx,2);
end

