dataRoot = 'C:\Users\psylab706\Documents\simnibs_examples';
subMark = 'ernie';
LF_Path = fullfile(dataRoot,subMark,'leadfieldAll');
LFfile = dir(fullfile(LF_Path,'*.hdf5'));
% tic
% lf = mesh_load_hdf5(fullfile(LFfile.folder,LFfile.name));
% disp(['Loading leadfield data consumes ' num2str(toc) ' seconds.']);
%% setting parameter
clipStr = 'y=24';
XupThres = 0.2; % the upbound of electric field
brainMaskIdx = [1,2];
couterMark = [1003];
%% tet intersection
node = lf(2).mesh.nodes;
elem = lf(2).mesh.tetrahedra;
brainMask = ismember(lf(2).mesh.tetrahedron_regions,brainMaskIdx);
DT = simpleTR(triangulation(double(elem(brainMask,:)),node));
[XYZmark,XYZvalue,dof] = str2XYZ(clipStr);
[TR,eIdx] = TetCrossSection(DT,clipStr);
E0 = permute(lf(2).lf.data(:,brainMask,:),[2,1,3]);
%% surf intersection 
[EV,p0,p1] = SurfCrossSection(dataRoot,subMark,clipStr,couterMark);
%% U input
% ROIname = 'lh.insula';
ROIname = 'lh.caudalanteriorcingulate';
% Upath = fullfile(dataRoot,subMark,'Result',ROIname,'P_1','R0_C2');
method_ROI = 0;
method_Cortex = 2;
elecNum = 6;
Penalty_coef = [1 2 2.5 3];
j = 4;
% Upath = fullfile(dataRoot,subMark,'Result',ROIname,'M1',['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
Upath = fullfile(dataRoot,subMark,'Result',ROIname,['P_' num2str(Penalty_coef(j))],['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
S = load(fullfile(Upath,['elec' num2str(elecNum) '.mat']));
U = eval(['S.U' num2str(elecNum) 'm']);
disp(U)
E_env= Onetime(E0,U);
x = vecnorm(E_env(eIdx,:),2,2)/1000;
%% figure and set color
h = figure;
axis equal;
h = plotCrossSection(h,TR,x,XupThres);
hold on;
h = plotContour(h,EV,dof,'k-','LineWidth',5);
axis off;

