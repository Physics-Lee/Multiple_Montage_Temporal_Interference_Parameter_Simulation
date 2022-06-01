function WMNT(dataRoot,subMark,DTImode)
t0 = tic;
baseDir = pwd;
% dataRoot = 'C:\Users\psylab706\Documents\simnibs_examples';
% subMark = 'ernie';
subDir = fullfile(dataRoot,subMark);
OriDir = fullfile(subDir,'orientation');
if ~exist(OriDir,'dir')
    mkdir(OriDir);
end
% DTImode = 2;
switch DTImode
    case 1 % get first eigenvector from nii2mesh in SIMNIBS
        tenserNii = [subMark '_tensor.msh'];
        tenserNiiDir = fullfile(subDir,tenserNii);
        if exist(tenserNiiDir,'file')==2
            disp('using already existed tensor msh file...');
        else
            disp('using nii2msh building tensor msh file...');
            cd(subDir);
            command = ['nii2msh -ev d2c_' subMark '/dti_results_T1space/DTI_conf_tensor.nii.gz ' subMark '.msh ' subMark '_tensor.msh'];
            status = system(command);
            cd(baseDir);
        end
        [m,fid] = mesh_load_gmsh4(tenserNiiDir);
        elemIdxWM = m.tetrahedron_regions==1;
        nt_elem_WM = m.element_data{1}.tetdata(elemIdxWM,:);
        nt_elem_WM = nt_elem_WM./vecnorm(nt_elem_WM,2,2);
%         nt1 = nt_elem_WM;
    case 2 % get first eigenvector from ACID pipeline
        disp('Get first eigenvector from ACID pipeline...');
        ACIDDir = fullfile(OriDir,'ACID');
        if ~exist(ACIDDir,'dir')
            mkdir(ACIDDir);
        %% prepare DTI raw file
        orgDir = fullfile(subDir,'org');
        gunzip(fullfile(orgDir,[subMark '*.gz']),ACIDDir);
        copyfile(fullfile(orgDir,[subMark '_dMRI.bval']),ACIDDir);
        copyfile(fullfile(orgDir,[subMark '_dMRI.bvec']),ACIDDir);
        disp('Copy nii files done.');
        %% prepare structure file
        gunzip(fullfile(subDir,['m2m_' subMark],'T1fs_conform.nii.gz'),ACIDDir);
        gunzip(fullfile(subDir,['m2m_' subMark],'T2_conform.nii.gz'),ACIDDir);
        %% ACID & SPM12
        cd(ACIDDir);
        spm('defaults', 'FMRI');
        ACID_job;
        spm_jobman('run', matlabbatch);
        cd(baseDir);
        else
            disp('ACID directory existed. Read data without running batches...');
        end
        %% read first eigenvector
        eVecFile_x = fullfile(ACIDDir,'rup',['NLLS_DTI_RBC_OFF_EVEC_cou2rup' subMark '_dMRI_00001-x1.nii']);
        eVecFile_y = fullfile(ACIDDir,'rup',['NLLS_DTI_RBC_OFF_EVEC_cou2rup' subMark '_dMRI_00001-y1.nii']);
        eVecFile_z = fullfile(ACIDDir,'rup',['NLLS_DTI_RBC_OFF_EVEC_cou2rup' subMark '_dMRI_00001-z1.nii']);
        vol_x = spm_vol(eVecFile_x);
        vol_y = spm_vol(eVecFile_y);
        vol_z = spm_vol(eVecFile_z);
        nt_x_vx = spm_read_vols(vol_x);
        nt_y_vx = spm_read_vols(vol_y);
        nt_z_vx = spm_read_vols(vol_z);
        [node,elem] = MeshfromSimnibs(dataRoot,subMark);
        DT_wm = triangulation(double(elem(elem(:,5)==1,1:4)),node);
        center_DT_wm = incenter(DT_wm);
        XYZq = mm2vx(vol_x.mat,center_DT_wm);
        [X,Y,Z] = meshgrid(1:vol_x.dim(2),1:vol_x.dim(1),1:vol_x.dim(3));
        nt_x = interp3(X,Y,Z, nt_x_vx,XYZq(:,2),XYZq(:,1),XYZq(:,3));
        nt_x(isnan(nt_x),:)=0;%% out boundary problem
        nt_y = interp3(X,Y,Z, nt_y_vx,XYZq(:,2),XYZq(:,1),XYZq(:,3));
        nt_y(isnan(nt_y),:)=0;
        nt_z = interp3(X,Y,Z, nt_z_vx,XYZq(:,2),XYZq(:,1),XYZq(:,3));
        nt_z(isnan(nt_z),:)=0;   
        nt_elem_WM = [nt_x,nt_y,nt_z]; 
    otherwise
            error('Wrong DTI mode in white mattar!');
end
saveFile = fullfile(OriDir,'nt_elem_WM.mat');
save(saveFile,'nt_elem_WM','-v7.3');
toc(t0);
%% point check
% pt0_mm= [10.5 -8.1 25.9];
% ID = pointLocation(DT_wm,pt0_mm);
% disp(nt1(ID,:));
% disp(nt2(ID,:));
%%
% DT0 = triangulation(DT_wm.ConnectivityList(1:k,:),DT_wm.Points);
% figure;
% showTR(DT0);
% hold on;
% k = 100;
% quiver3(center_DT_wm(1:k,1),center_DT_wm(1:k,2),center_DT_wm(1:k,3),nt1(1:k,1),nt1(1:k,2),nt1(1:k,3),'r') ;
% quiver3(center_DT_wm(1:k,1),center_DT_wm(1:k,2),center_DT_wm(1:k,3),nt2(1:k,1),nt2(1:k,2),nt2(1:k,3),'g') ;