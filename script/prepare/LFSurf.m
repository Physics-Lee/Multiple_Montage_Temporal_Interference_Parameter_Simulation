function [Data,gmS] = LFSurf(dataRoot,subMark)
% define leadfield in gray matter surface
% atlas: "'DK40'" or "MNI_Coord" in simNIBS
LFPath = fullfile(dataRoot,subMark,'leadfield');
LFFile = fullfile(LFPath,[subMark '_leadfield_EEG10-10_UI_Jurak_2007.hdf5']);
if exist(LFFile,'file')~=2
    error('Leadfield file for gray matter surface not existed! Please run prepare script.');
end
m0 = mesh_load_hdf5(LFFile);
m1 = m0(2).mesh;
node_1006_idx = unique(m1.triangles(m1.triangle_regions==1006,:));
gmS = mesh_extract_regions(m1, 'region_idx', [1 2]); % gray matter surface in both hemisphere
Data.areas = single(mesh_get_node_areas(gmS));
TR = triangulation(double(gmS.triangles),gmS.nodes);
Data.nt = single(vertexNormal(TR));
Data.electrodes = m0(2).lf.properties.electrode_names; %电极名称
n = size(m0(2).mesh.nodes,1);
E = zeros(n,3,76);
E(:,:,2:end) = permute(m0(2).lf.data,[2,1,3]);
E(node_1006_idx,:,:)=[];
Data.E = single(E/1000); % scale
end



