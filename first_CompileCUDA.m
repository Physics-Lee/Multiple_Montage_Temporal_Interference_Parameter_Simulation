% this script is used to compile CUDA

root = pwd;
codepath = fullfile(root,'script','CUDA');
%% gpu compile
cd(codepath);
%% ROI
compileTI('ROIPhase');
compileTI('ROIPhaseNt');
%% multi-electrode
compileTI('MultiElec');
compileTI('MultiElecNt');
%%
cd(root);
disp('Cuda Mex all success...');