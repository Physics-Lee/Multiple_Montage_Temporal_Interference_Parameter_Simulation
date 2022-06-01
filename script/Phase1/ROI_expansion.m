function gray_matter = ROI_expansion(gray_matter,multiple)
% 找到与ROI边缘顶点相邻的网格，将ROI区域一层一层向外扩，直到面积超过设定的阈值

ROI_mesh = mesh_extract_regions(gray_matter, 'region_idx', 1234); 
ROI_areas = mesh_get_node_areas(ROI_mesh);
ROI_mesh_ori = ROI_mesh;
ROI_areas_ori = ROI_areas;
ROI_ID = find(gray_matter.triangle_regions == 1234);
newID = ROI_ID; %以ROI的ID初始化

while(1)
if sum(ROI_areas) >= sum(ROI_areas_ori)*multiple
    disp('The ROI expansion has finished.')
    break;
end

TR_ROI = triangulation(ROI_mesh.triangles,ROI_mesh.nodes);
[F,Pf] = freeBoundary(TR_ROI);
hold on
plot3(Pf(:,1),Pf(:,2),Pf(:,3),'-r','LineWidth',2);

TR = triangulation(gray_matter.triangles,gray_matter.nodes);
[~,ia,ib] = intersect(TR.Points,Pf,'rows');
[Sib,Iib] = sort(ib);
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
gray_matter.triangle_regions(new_tri,:) = 5678;

%% 计算面积
ROI_mesh = mesh_extract_regions(gray_matter, 'region_idx', [1234 5678]); 
ROI_areas = mesh_get_node_areas(ROI_mesh);

end
%% 绘图
newROI_mesh = mesh_extract_regions(gray_matter, 'region_idx', 5678); 
trimesh(newROI_mesh.triangles,newROI_mesh.nodes(:,1),newROI_mesh.nodes(:,2),...
    newROI_mesh.nodes(:,3),'EdgeColor','k',...
    'FaceColor', [0/255 0/255 139/255],'FaceAlpha',1);
hold on
trimesh(ROI_mesh_ori.triangles,ROI_mesh_ori.nodes(:,1),ROI_mesh_ori.nodes(:,2),...
    ROI_mesh_ori.nodes(:,3),'EdgeColor','k',...
    'FaceColor', [139/255 0/255 0/255],'FaceAlpha',1);





