% this function is used to ???

function target_node_idx_all = TargetTet(dataRoot,subMark,mesh,cfgTarget)
m2mPath = fullfile(dataRoot,subMark, ['m2m_' subMark]);
DT = mesh.DT;
center = incenter(DT);
target_node_idx = false(size(DT,1),cfgTarget.num);
%%
for i = cfgTarget.num 
    tmp = cfgTarget.table(i,:);
    switch tmp.Shape
        case 'AAL3'  
            disp(['Define target using atlas ' tmp.Shape '...']);
            target_coord_MNI = AAL3ROI(tmp.Name);
        case 'JHU_ICBM'
            disp(['Define target using atlas ' tmp.Shape '...']);
            target_coord_MNI = JHU_ICBM_ROI(tmp.Name);
        case 'Sphere'
            target_coord_MNI = tmp.CoordMNI;   
        otherwise
            error('Wrong target type define!');
    end
    target_coord_sub = mni2subject_coords(target_coord_MNI, m2mPath); % transform to subject space
    ID = knnsearch(target_coord_MNI,center);
    target_node_idx(:,i) = vecnorm(center-target_coord_sub(ID,:),2,2)<tmp.Radius;
end
target_node_idx_all = any(target_node_idx,2);
%%
% elem_label = (1:size(DT))';
% % elem_idx = ismember(elem5,cfgTarget.matter);
% elem1 = DT.ConnectivityList(elem_idx,:);
% elem1_label = elem_label(elem_idx);
% %%
% DT1 = simpleTR(triangulation(elem1,DT.Points));
% ID1 = pointLocation(DT1,coord_sub);
% ID1 = ID1(~isnan(ID1));
% ID1_u = unique(ID1);
% ROI_idx = false(size(DT,1),1);
% ROI_idx(elem1_label(ID1_u)) = true;
end