function [Dispersion] = DispersionCortex(thresCortex_mesh)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% thresCortex_mesh = mesh_extract_regions(gray_matter, 'region_idx', thresCortex_label);
TR_Cortex = triangulation(thresCortex_mesh.triangles,thresCortex_mesh.nodes);
C = incenter(TR_Cortex);
S = elemvolume(TR_Cortex.Points,TR_Cortex.ConnectivityList,'signed');
GC_Cortex = sum(C.*S/sum(S));
Dispersion = sqrt(sum(sum(bsxfun(@minus,[thresCortex_mesh.nodes],GC_Cortex).^2,2))/size(thresCortex_mesh.nodes,1));%类似于标准差
end

