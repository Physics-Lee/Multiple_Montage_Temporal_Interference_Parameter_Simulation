function [cfg,elec4] = upload_cfg_and_elec4(directory)
load(fullfile(directory,'cfg.mat'),'cfg'); % upload cfg.mat % In this way, MATLAB won't warn me.
global montage_number_after_Phase_1;
elec4 = load(fullfile(directory,['elec4_Exhaustion_T1_' num2str(montage_number_after_Phase_1) '_PenaltyCoefficient_1.mat'])); % upload elec4.mat
end
