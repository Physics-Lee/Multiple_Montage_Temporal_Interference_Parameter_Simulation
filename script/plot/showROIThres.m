function [Area_ROI,Area_Cortex,Area_Penalty,Dispersion] = showROIThres(gray_matter,thresROI_label,thresCortex_label,thresPenalty_label)

thresROI_mesh = mesh_extract_regions(gray_matter, 'region_idx', thresROI_label);
thresCortex_mesh = mesh_extract_regions(gray_matter, 'region_idx', thresCortex_label);
thresPenalty_mesh = mesh_extract_regions(gray_matter, 'region_idx', thresPenalty_label);

try
    Num_nodes_ROI = size(thresROI_mesh.nodes,1);
    % Num_nodes_Cortex = size(thresCortex_mesh.nodes,1);
    Area_ROI = sum(mesh_get_node_areas(thresROI_mesh));
    Area_Cortex = sum(mesh_get_node_areas(thresCortex_mesh));
%     GC = mean([thresROI_mesh.nodes;thresCortex_mesh.nodes]);
%     Dispersion = sqrt(sum(sum(bsxfun(@minus,[thresROI_mesh.nodes;thresCortex_mesh.nodes],GC).^2,2))/Num_nodes_ROI);%类似于标准差
    Dispersion = DispersionCortex(thresCortex_mesh);
    TR = triangulation(double(gray_matter.triangles),gray_matter.nodes);
    TR_thresROI = triangulation(double(thresROI_mesh.triangles),thresROI_mesh.nodes);
    TR_thresCortex = triangulation(double(thresCortex_mesh.triangles),thresCortex_mesh.nodes);
    
    if ~isempty(thresPenalty_label)
        Area_Penalty = sum(mesh_get_node_areas(thresPenalty_mesh));
        TR_thresPenalty = triangulation(double(thresPenalty_mesh.triangles),thresPenalty_mesh.nodes);
        showTR_facealpha(TR,TR_thresPenalty,[0,139,139]);
        hold on
    else
        Area_Penalty = [];
    end
    
    % figure;
    hp = gca;
    showTR_facealpha(TR,TR_thresROI,[238,118,0]);
    hold on
    showTR_facealpha(TR,TR_thresCortex,[153,50,204]);
    set(gca,'color','none');
    
    axis equal;
    axis vis3d
    axis off
    view(gca,[0 0]);
    material(hp,'dull');
    lighting gouraud
    hlight=camlight('headlight');
    set(gca,'UserData',hlight);
    hrot = rotate3d;
    set(hrot,'ActionPostCallback',@(~,~)camlight(get(gca,'UserData'),'headlight'));
end