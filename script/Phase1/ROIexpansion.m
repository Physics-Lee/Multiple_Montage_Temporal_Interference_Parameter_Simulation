gray_matter = ROI_expansion(gray_matter,ROI.multiple);

Cortex_mesh = mesh_extract_regions(gray_matter, 'region_idx', [1 2]);
[~,iaC,~] = intersect(gray_matter.nodes,Cortex_mesh.nodes,'rows');
LF.OutROI_idx = false(size(gray_matter.nodes,1),1);
LF.OutROI_idx(iaC) = true;

ROI_mesh = mesh_extract_regions(gray_matter, 'region_idx', 1234);
[~,iaR,~] = intersect(gray_matter.nodes,ROI_mesh.nodes,'rows');
LF.ROI_idx = false(size(gray_matter.nodes,1),1);
LF.ROI_idx(iaR) = true;

%% 如果multiple<=1，ROI不进行拓展，上述提取的ROI和Cortex边缘会在两个里面都取一次
% 将边缘从Cortex中去掉
TR_C = triangulation(Cortex_mesh.triangles,Cortex_mesh.nodes);
[~,Pf] = freeBoundary(TR_C);
[~,iaPf,~] = intersect(gray_matter.nodes,Pf,'rows');
LF.OutROI_idx(iaPf) = false;

switch Cortex.method
    case 'OutROI'
        LF.Cortex_coef = LF.OutROI_idx.*1;
    case 'DK40'  % 按照脑区选取的惩罚区域标签为 666
        for i_ca = 1:size(Cortex.penalty_areas,1)
            % Load the atlas and define the brain region of interest
            [labels, snames] = subject_atlas(gray_matter, ...
                fullfile(datapath, ['m2m_' subname]), 'DK40');%DK40
            region_name = Cortex.penalty_areas{i_ca,1};
            cor_idx = find(strcmpi(snames, region_name));
            node_idx_Cortex = labels.node_data{end}.data == cor_idx;
            
            gray_matter.node_data{end+1}.data = int8(node_idx_Cortex);
            gray_matter.node_data{end}.name = region_name;
            % mesh_show_surface(gray_matter, 'field_idx', region_name)
            
            Cor_idx = gray_matter.node_data{end}.data == 1;
            % LF.OutROI_idx = ~gray_matter.node_data{end}.data;
            
            Cor_node_num = find(Cor_idx);
            for i_facenode = 1:size(gray_matter.triangles,1)
                isCor(i_facenode) = all(ismember(gray_matter.triangles(i_facenode,1:3),Cor_node_num'));%三角形的三个顶点全部为Cor_node
            end
            gray_matter.triangle_regions(isCor',1) = 666;
            gray_matter = Region_edge_expansion(gray_matter,666);
        end
        
        Cortex_penalty_mesh = mesh_extract_regions(gray_matter, 'region_idx', 666);
        [~,iaC,~] = intersect(gray_matter.nodes,Cortex_penalty_mesh.nodes,'rows');
        LF.OutROI_penalty_idx = false(size(gray_matter.nodes,1),1);
        LF.OutROI_penalty_idx(iaC) = true;
        
        [CR,~,~] = intersect(Cortex_penalty_mesh.nodes,ROI_mesh.nodes,'rows');
        [~,iaCR,~] = intersect(gray_matter.nodes,CR,'rows');
        LF.OutROI_penalty_idx(iaCR) = false;%从Cortex中去掉与ROI重合的点
        
        LF.Cortex_coef = single(LF.OutROI_idx);
        LF.Cortex_coef(find(LF.OutROI_penalty_idx)) = Cortex.penalty_coef; %惩罚区域相应的惩罚系数，非惩罚区域系数为1
    case 'MNI_Coord'  % 按照MNI坐标选取的惩罚区域标签为 888
        for i_ca = 1:size(Cortex.penalty_areas,1)
            % Load the atlas and define the brain region of interest
            Coord_MNI_Cortex = Cortex.penalty_areas(i_ca,1:3);
            coords_sub_Cortex = mni2subject_coords(Coord_MNI_Cortex, fullfile(datapath, ['m2m_' subname]));%坐标转换
            I_coords_sub_Cortex = dsearchn(gray_matter.nodes,coords_sub_Cortex);
            coords_sub_Cortex = gray_matter.nodes(I_coords_sub_Cortex,:);%邻近的网格顶点
            dist = sqrt(sum(bsxfun(@minus,gray_matter.nodes,coords_sub_Cortex).^2,2));
            node_idx_Cortex = dist < Cortex.r;
            
            gray_matter.node_data{end+1}.data = int8(node_idx_Cortex);
            gray_matter.node_data{end}.name = region_name;
            % mesh_show_surface(gray_matter, 'field_idx', region_name)
            
            Cor_idx = gray_matter.node_data{end}.data == 1;
            % LF.OutROI_idx = ~gray_matter.node_data{end}.data;
            
            Cor_node_num = find(Cor_idx);
            for i_facenode = 1:size(gray_matter.triangles,1)
                isCor(i_facenode) = all(ismember(gray_matter.triangles(i_facenode,1:3),Cor_node_num'));%三角形的三个顶点全部为Cor_node
            end
            gray_matter.triangle_regions(isCor',1) = 888;
            gray_matter = Region_edge_expansion(gray_matter,888);
        end
        
        Cortex_penalty_mesh = mesh_extract_regions(gray_matter, 'region_idx', 888);
        [~,iaC,~] = intersect(gray_matter.nodes,Cortex_penalty_mesh.nodes,'rows');
        LF.OutROI_penalty_idx = false(size(gray_matter.nodes,1),1);
        LF.OutROI_penalty_idx(iaC) = true;
        
        [CR,~,~] = intersect(Cortex_penalty_mesh.nodes,ROI_mesh.nodes,'rows');
        [~,iaCR,~] = intersect(gray_matter.nodes,CR,'rows');
        LF.OutROI_penalty_idx(iaCR) = false;%从Cortex中去掉与ROI重合的点
        
        LF.Cortex_coef = single(LF.OutROI_idx);
        LF.Cortex_coef(find(LF.OutROI_penalty_idx)) = Cortex.penalty_coef; %惩罚区域相应的惩罚系数，非惩罚区域系数为1
    otherwise
        disp('Wrong Cortex.method, please check...');
        return;
end

LF.gray_matter = gray_matter;
