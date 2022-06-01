function GMNT(dataRoot,subMark)
%% GM middle layer
disp('Extract middle layer of gray matter from leadfield folder...');
tic
LF_SurfPath = fullfile(dataRoot,subMark,'leadfield');
LFfile = dir(fullfile(LF_SurfPath,'*.hdf5'));
surf = mesh_load_hdf5(fullfile(LFfile.folder,LFfile.name));
faceM = double(surf(2).mesh.triangles(ismember(surf(2).mesh.triangle_regions,[1,2]),:)); % 1 left, 2 right, 1006 eye
nodeM = surf(2).mesh.nodes;
TR_mid = triangulation(faceM,nodeM);
center_TR_mid = incenter(TR_mid);
nt_mid = faceNormal(TR_mid);
toc
%% GM tet mesh
disp('Extract GM and WM surface from Mesh msh file...');
tic
[node,elem,simNIBS_face] = MeshfromSimnibs(dataRoot,subMark);
GMsurf = simNIBS_face(simNIBS_face(:,4)==1002,1:3);
TR_GM = simpleTR(triangulation(double(GMsurf),node));
WMsurf = simNIBS_face(simNIBS_face(:,4)==1001,1:3);
TR_WM = simpleTR(triangulation(double(WMsurf),node));
toc
%% plot check
% figure;hold on;
% plotmesh(TR_mid.Points,TR_mid.ConnectivityList,'y>-3','Facecolor','r','EdgeColor','none');
% plotmesh(TR_GM.Points,TR_GM.ConnectivityList,'y>-3','Facecolor','g','EdgeColor','none');
% plotmesh(TR_WM.Points,TR_WM.ConnectivityList,'y>-3','Facecolor','b','EdgeColor','none');
%% get middle layer normal intersect Line
disp('get middle layer normal intersect Line...');
Vedge = gmNTCore(TR_mid,TR_GM,TR_WM,nt_mid,center_TR_mid);
%% get normal vector for every tet element
disp('get normal vector for every tet element...')
elem_GM = elem(elem(:,5)==2,1:4);
DT_GM = simpleTR(triangulation(double(elem_GM),node));
center_DT_GM = incenter(DT_GM);
N = size(elem_GM,1);
k = zeros(N,1);
N_local = 50;
idx = knnsearch(center_TR_mid,center_DT_GM,'K',N_local); % local part
d = zeros(N_local,3);
for i = 1:N
    d(:,1) = vecnorm(center_DT_GM(i,:)-Vedge(idx(i,:),:,1),2,2);
    d(:,2) = vecnorm(center_DT_GM(i,:)-Vedge(idx(i,:),:,2),2,2);
    d(:,3) = abs(nt_mid(idx(i,:),:)*(center_DT_GM(i,:)).');
    [d1,j1] = min(d);
    [~,j2] = min(d1);
    k(i) = idx(i,j1(j2));
end
nt_elem_GM = nt_mid(k,:);
savePath = fullfile(dataRoot,subMark,'orientation');
if ~exist(savePath,'dir')
    mkdir(savePath);
end
saveFile = fullfile(savePath,'nt_elem_GM.mat');
save(saveFile,'nt_elem_GM','-v7.3');
end
%% plot check
% i = 1;
% pt0 = center_DT_GM(i,:);
% nt0 = nt_mid(k(i),:);
% figure;hold on;
% plot3v(pt0,'r*');
% TR_mid_local = triangulation(TR_mid.ConnectivityList(idx(i,:),:),TR_mid.Points);
% showTR(TR_mid_local);
% vv = Vedge(idx(i,:),:,:);
% for j = 1:N_local
%     plot3v(permute(vv(j,:,:),[3,2,1]),'k-');
% end
% vv = permute(Vedge(k(i),:,:),[3,2,1]);
% plot3v(vv,'g-');
% center_mid0 = center_TR_mid(k(i),:);
% plot3v(center_mid0,'g*');
% d0 = -dot(center_mid0,nt0);
% ptH = Pt2LineFoot(pt0,nt0,d0,center_mid0);
% plot3v(ptH,'bs');
% vv = [pt0;ptH];
% plot3v(vv,'b-');






