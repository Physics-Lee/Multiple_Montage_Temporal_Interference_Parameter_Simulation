function [ROI_coord_MNI,TR] = AAL3ROI(label)
p = mfilename('fullpath');
AAL3Dir = fullfile(fileparts(fileparts(fileparts(p))),'ATLAS','AAL3');
txtFile = fullfile(AAL3Dir,'AAL3v1_1mm.nii.txt');
niiFile = fullfile(AAL3Dir,'AAL3v1_1mm.nii');
labelPool = readtable(txtFile,'range','A1:B170');
idx = find(strcmp(label,labelPool.Var2));
if isempty(idx)
    disp('No corresponding label for this target!');
    ROI_coord_MNI = zeros(0,3);
else
    v = spm_vol(niiFile);
    data=spm_read_vols(v);
    data1 = false(size(data));
    data1(data == idx) = true;
    [vx,vy,vz] = ind2sub(size(data1),find(data1));
    ROI_coord_MNI = vx2mm(v.mat,[vx,vy,vz]);
end
%%
[x,y,z] = meshgrid(1:v.dim(2),1:v.dim(1),1:v.dim(3));
s = isosurface(x,y,z,data1,1e-4);
node = vx2mm(v.mat,[s.vertices(:,2),s.vertices(:,1),s.vertices(:,3)]);
TR = triangulation(s.faces,node);
end

