function [gray_matter] = Cortex_thres(gray_matter,thres,ROI_label,Cortex_label,penalty_label)
% maxColor设置colorbar的最大值，如果为空就设为全脑场强的最大值；
thres_idx = gray_matter.node_data{1,1}.data > thres;
% nodes_areas = mesh_get_node_areas(gray_matter);
Thres_node_num = find(thres_idx);
supra_thres = all(ismember(gray_matter.triangles(:,1:3),Thres_node_num),2)';%三角形的三个顶点全部为ROI_node
thres_ROI = supra_thres' & gray_matter.triangle_regions == ROI_label;
gray_matter.triangle_regions(thres_ROI,1) = 9001;% 超过阈值的ROI区域标记为9001
%%
idx_cortex = true(size(gray_matter.triangle_regions));
for i = 1:length(Cortex_label)
    idx_Cortex(:,i) = idx_cortex & gray_matter.triangle_regions == Cortex_label(i);
end
idx_Cortex = sum(idx_Cortex,2) > 0;
thres_Cortex = supra_thres' & idx_Cortex;
gray_matter.triangle_regions(thres_Cortex,1) = 9002;% 超过阈值的Cortex(irrelevant)区域标记为9002
%%
if ~isempty(penalty_label)
    idx_penalty = true(size(gray_matter.triangle_regions));
    for j = 1:length(penalty_label)
        idx_Penalty(:,i) = idx_penalty & gray_matter.triangle_regions == penalty_label(j);
    end
    idx_Penalty = sum(idx_Penalty,2) > 0;
    thres_penalty = supra_thres' & idx_Penalty;
    gray_matter.triangle_regions(thres_penalty,1) = 9003;% 超过阈值的penalty区域标记为9003
end

%%
% Num_nodes_ROI = sum(thres_ROI);
% Num_nodes_Cortex = sum(thres_Cortex);







