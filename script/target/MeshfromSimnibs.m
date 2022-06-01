function [node,elem,simNIBS_face,conduct] = MeshfromSimnibs(dataRoot,sub_mark)
% [node,elem,conduct] = MeshfromSimnibs(dataRoot,sub_mark)
% import mesh from SimNIBS folder
% code by Z.W.
file = fullfile(dataRoot,sub_mark,[sub_mark '.msh']);
mesh = mesh_load_gmsh4(file);
node = mesh.nodes;
simNIBS_face = mesh.triangles;
elem = mesh.tetrahedra;
simNIBS_face(:,4) = mesh.triangle_regions;
elem(:,5) = mesh.tetrahedron_regions;
conduct=mat_conduct_simnibs(mesh.tetrahedron_regions);
elem = double(elem);
end

