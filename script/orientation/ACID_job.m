%-----------------------------------------------------------------------
% Job saved on 16-Nov-2021 14:29:44 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% subMark = 'ernie';
upRaw = fullfile(pwd,[subMark '_dMRI.nii']);
dwRaw = fullfile(pwd,[subMark '_dMRI_rev.nii']);
upBvalFile = fullfile(pwd,[subMark '_dMRI.bval']);
upBvecFile = fullfile(pwd,[subMark '_dMRI.bvec']);
%% structure image
T1File = 'T1fs_conform.nii';
T2File = 'T2_conform.nii';
HYSCO_dir = fullfile(pwd,'rup');
if ~exist(HYSCO_dir,'dir')
    mkdir(HYSCO_dir);
end
rupDir = fullfile(pwd,'rup');
if ~exist(rupDir,'dir')
    mkdir(rupDir);
end
%%
Vup = spm_vol(upRaw);
upN =  length(Vup);
Vdw = spm_vol(dwRaw);
dwN =  length(Vdw);
fileID = fopen(upBvecFile,'r');
tmp = fscanf(fileID,'%lf');
bvecUp = reshape(tmp,upN,[])';
fclose(fileID);
fileID = fopen(upBvalFile,'r');
tmp = fscanf(fileID,'%lf');
bvalUp = tmp';
fclose(fileID);
BvalDw_exp = zeros(1,dwN);
%% initial default set
[r,z,i]=fileparts(which('acid_local_defaults.m'));
spm_path = r(1:end-25);
local_defaults_path = [r filesep z i];
matlabbatch{1}.spm.tools.dti.acid_config.acid_setdef.customised = {local_defaults_path};
%% ECMOCO for up dMRI.nii
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_sources = {[upRaw ',1']};
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_dummy_type = 0;
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_dof1_type.ecmoco2_dof1_exp = [1 1 1 1 1 1 0 1 0 1 1 0];
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_dof2_type.ecmoco2_dof2_exp = [0 1 0 0 1 0 0];
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_bvals_type.ecmoco2_bvals_file = {upBvalFile};
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco_dummy_single_or_multi_target = false;
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_target = {''};
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_dummy_init = true;
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_excluded = {''};
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_mask = {''};
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_zsmooth = 0;
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_biasfield = {''};
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_prefix = 'rup';
matlabbatch{2}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco_parallel_prog = 4;
%% ECMOCO for down dMRI_rev.nii
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_sources = {[dwRaw ',1']};
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_dummy_type = 0;
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_dof1_type.ecmoco2_dof1_exp = [1 1 1 1 1 1 0 1 0 1 1 0];
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_dof2_type.ecmoco2_dof2_exp = [0 1 0 0 1 0 0];
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_bvals_type.ecmoco2_bvals_exp = BvalDw_exp;
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco_dummy_single_or_multi_target = false;
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_target = {''};
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_dummy_init = true;
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_excluded = {''};
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_mask = {''};
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_zsmooth = 0;
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_biasfield = {''};
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco2_prefix = 'rdw';
matlabbatch{3}.spm.tools.dti.prepro_choice.ecmo_choice.ecmoco2.ecmoco_parallel_prog = 4;
%% rup 4d to 3d
matlabbatch{4}.spm.util.split.vol = {fullfile(pwd,['rup' subMark '_dMRI.nii,1'])};
matlabbatch{4}.spm.util.split.outdir = {rupDir};
%% HYSCO
matlabbatch{5}.spm.tools.dti.prepro_choice.hysco_choice.hysco2.source_up(1) = cfg_dep('Estimate & write ECMOCO: Average b0 image (resliced)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','b0'));
matlabbatch{5}.spm.tools.dti.prepro_choice.hysco_choice.hysco2.source_dw(1) = cfg_dep('Estimate & write ECMOCO: Average b0 image (resliced)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','b0'));
matlabbatch{5}.spm.tools.dti.prepro_choice.hysco_choice.hysco2.others_up(1) = cfg_dep('4D to 3D File Conversion: Series of 3D Volumes', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','splitfiles'));
matlabbatch{5}.spm.tools.dti.prepro_choice.hysco_choice.hysco2.others_dw = {''};
matlabbatch{5}.spm.tools.dti.prepro_choice.hysco_choice.hysco2.perm_dim = 2;
matlabbatch{5}.spm.tools.dti.prepro_choice.hysco_choice.hysco2.dummy_fast = 1;
matlabbatch{5}.spm.tools.dti.prepro_choice.hysco_choice.hysco2.dummy_ecc = 0;
matlabbatch{5}.spm.tools.dti.prepro_choice.hysco_choice.hysco2.dummy_3dor4d = 0;
%% File split 
matlabbatch{6}.cfg_basicio.file_dir.file_ops.cfg_file_split.name = 'u2rup';
matlabbatch{6}.cfg_basicio.file_dir.file_ops.cfg_file_split.files(1) = cfg_dep('HySCO: Unwarped Blip up images', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rothers_up'));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.cfg_file_split.index = {1};
%% Coregistration ECMOCO & HYSCO corrected up dMRI to T1 structrue image
matlabbatch{7}.spm.spatial.coreg.estwrite.ref = {fullfile(pwd,[T1File ',1'])};
matlabbatch{7}.spm.spatial.coreg.estwrite.source(1) = cfg_dep('File Set Split: u2rup (1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('{}',{1}));
matlabbatch{7}.spm.spatial.coreg.estwrite.other(1) = cfg_dep('File Set Split: u2rup (rem)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('{}',{2}));
matlabbatch{7}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{7}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{7}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{7}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{7}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{7}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{7}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{7}.spm.spatial.coreg.estwrite.roptions.prefix = 'co';
%% Coregistration T2 to T1 structrue image
matlabbatch{8}.spm.spatial.coreg.estwrite.ref = {fullfile(pwd,[T1File ',1'])};
matlabbatch{8}.spm.spatial.coreg.estwrite.source = {fullfile(pwd,[T2File ',1'])};
matlabbatch{8}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{8}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{8}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{8}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{8}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{8}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{8}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{8}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{8}.spm.spatial.coreg.estwrite.roptions.prefix = 'co';
%% Segment 
matlabbatch{9}.spm.spatial.preproc.channel(1).vols = {fullfile(pwd,[T1File ',1'])};
matlabbatch{9}.spm.spatial.preproc.channel(1).biasreg = 0.001;
matlabbatch{9}.spm.spatial.preproc.channel(1).biasfwhm = 60;
matlabbatch{9}.spm.spatial.preproc.channel(1).write = [0 0];
matlabbatch{9}.spm.spatial.preproc.channel(2).vols = {fullfile(pwd,['co' T2File ',1'])};
matlabbatch{9}.spm.spatial.preproc.channel(2).biasreg = 0.001;
matlabbatch{9}.spm.spatial.preproc.channel(2).biasfwhm = 60;
matlabbatch{9}.spm.spatial.preproc.channel(2).write = [0 0];
matlabbatch{9}.spm.spatial.preproc.tissue(1).tpm = {[spm_path 'tpm\TPM.nii,1']};
matlabbatch{9}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{9}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{9}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{9}.spm.spatial.preproc.tissue(2).tpm = {[spm_path 'tpm\TPM.nii,2']};
matlabbatch{9}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{9}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{9}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{9}.spm.spatial.preproc.tissue(3).tpm = {[spm_path 'tpm\TPM.nii,3']};
matlabbatch{9}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{9}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{9}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{9}.spm.spatial.preproc.tissue(4).tpm = {[spm_path 'tpm\TPM.nii,4']};
matlabbatch{9}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{9}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{9}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{9}.spm.spatial.preproc.tissue(5).tpm = {[spm_path 'tpm\TPM.nii,5']};
matlabbatch{9}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{9}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{9}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{9}.spm.spatial.preproc.tissue(6).tpm = {[spm_path 'tpm\TPM.nii,6']};
matlabbatch{9}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{9}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{9}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{9}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{9}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{9}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{9}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{9}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{9}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{9}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{9}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{9}.spm.spatial.preproc.warp.bb = [NaN NaN NaN; NaN NaN NaN];
%% BrainMask
matlabbatch{10}.spm.tools.dti.misc_choice.make_brainMSK.make_brainMSK_PSEG(1) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
matlabbatch{10}.spm.tools.dti.misc_choice.make_brainMSK.make_brainMSK_PSEG(2) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
matlabbatch{10}.spm.tools.dti.misc_choice.make_brainMSK.make_brainMSK_PDTI = {''};
matlabbatch{10}.spm.tools.dti.misc_choice.make_brainMSK.make_brainMSK_perc = 0.76;
matlabbatch{10}.spm.tools.dti.misc_choice.make_brainMSK.make_brainMSK_smk = [3 3 3];
%% DTI fit
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.in_vols_GN(1) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.diff_dirs_GN = bvecUp;
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.b_vals_GN = bvalUp;
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.dummy_algorithm_GN = 1;
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.dummy_RBC_GN = 0;
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.in_sigma_RBC = 10;
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.in_msk_GN(1) = cfg_dep('Make Brain Mask: Brain Mask', substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BMSKfiles'));
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.RMatrix_GN = [1 0 0; 0 1 0;0 0 1];
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.in_L_RBC = 1;
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.in_noise_map_GN = {''};
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.in_npool = 4;
matlabbatch{11}.spm.tools.dti.fit_choice.dti_choice.diff_GN.dummy_DT = 0;
