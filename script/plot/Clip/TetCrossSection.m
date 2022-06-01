function [TR,eIdx] = TetCrossSection(DT,str)
% TetCrossSection aims to get the cross section of a tetrahedron mesh
% It also gives the idx of the mesh element for subsequent interpolation operations
% written by Wei Zhang, 2021
% Input arguments: 
% DT, tetrahedron mesh
% nt, cross section plane normal vector
% d, cross section plane translation 
% Output arguments: 
% TR, the new cross section triangle mesh
% eIdx, the corresponding list for every triangle in TR to every element in DT
[XYZmark,XYZvalue,dof] = str2XYZ(str);
nt = zeros(3,1);
nt(XYZmark) = 1;
d = -XYZvalue;
node = DT.Points;
elem = DT.ConnectivityList;
NT = size(elem,1);
eIdx0 = (1:NT)';
edge = [elem(:,[1,2]);elem(:,[1,3]);elem(:,[1,4]);elem(:,[2,3]);elem(:,[2,4]);elem(:,[3,4])];
v0a = node(edge(:,1),:);
v0b = node(edge(:,2),:);
d0a = v0a*nt+d;
d0b = v0b*nt+d;
idx_edgeIntersect = d0a.*d0b<0;
v1a = v0a(idx_edgeIntersect,:);
v1b = v0b(idx_edgeIntersect,:);
e1 = v1a-v1b;
e1_nt = bsxfun(@rdivide,e1,vecnorm(e1,2,2));
t = - (v1a*nt+d) ./ (e1_nt*nt);
V = v1a + e1_nt.*t;
Vidx = zeros(NT*6,1);
%% debug
% pt0 = [-78.251,
% d0 = 
%%
Vidx(idx_edgeIntersect) = (1:sum(idx_edgeIntersect))';
%%
idx_edgeIntersect6 = reshape(idx_edgeIntersect,[],6);
Vidx6 = reshape(Vidx,[],6);
key = sum(idx_edgeIntersect6,2);
idx3 = ismember(key,3);% 3 edge intersect with cross plane
tmp3 = sort(Vidx6(idx3,:),2);
face3 = tmp3(:,4:6);
eIdx3 = eIdx0(idx3);
idx4 = ismember(key,4);% 4 edge intersect with cross plane
tmp4 = sort(Vidx6(idx4,:),2);
face4 = [tmp4(:,3:5);tmp4(:,4:6)];
eIdx4 = repmat(eIdx0(idx4),2,1);
%%
face = [face3;face4];
eIdx = [eIdx3;eIdx4];
V = V(:,dof);
TR = triangulation(face,V);


