% this script is used to add path

%% addPath
root = pwd;
codepath = fullfile(root,'script');
addpath(genpath(codepath));
disp('add path success...');

%% save path permanently
savepath;