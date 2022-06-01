function gray_matter = Region_edge_expansion(gray_matter,num_label)
% 找到与ROI边缘顶点相邻的网格，将ROI区域边缘向外拓展一圈，
% 从而避免对多个相邻的ROI进行选取的时候相接的边缘选不到的问题
% num_label 为需要边缘扩展的区域的编码

ROI_mesh = mesh_extract_regions(gray_matter, 'region_idx', num_label); 
ROI_areas = mesh_get_node_areas(ROI_mesh);

ROI_ID = find(gray_matter.triangle_regions == num_label);
newID = ROI_ID; %以ROI的ID初始化


TR_ROI = triangulation(ROI_mesh.triangles,ROI_mesh.nodes);
[F,Pf] = freeBoundary(TR_ROI);

TR = triangulation(gray_matter.triangles,gray_matter.nodes);
[~,ia,ib] = intersect(TR.Points,Pf,'rows');
[~,Iib] = sort(ib);
Sia = ia(Iib);
Ftr = Sia(F);
Ftr = unique(reshape(Ftr,size(Ftr,1)*2,1));
ID = vertexAttachments(TR,Ftr);
allID = [];
for i_id = 1:size(ID,1)
    allID = [allID;ID{i_id,1}.'];
end
allID = unique(allID);
newID = unique([allID;newID]);
new_tri = setdiff(newID,ROI_ID,'rows');
gray_matter.triangle_regions(new_tri,:) = num_label;







