function [cfg,elec4] = upload_cfg_and_elec4(directory_of_cfg)
load(fullfile(directory_of_cfg,'cfg.mat'),'cfg'); % upload cfg.mat % In this way, MATLAB won't warn me.
global montage_number_after_Phase_1;
montage_number_after_Phase_1 = cfg.montage_number_after_phase_1;
elec4 = load(fullfile(directory_of_cfg,['elec4_Exhaustion_T1_' num2str(montage_number_after_Phase_1) '_PenaltyCoefficient_1.mat'])); % upload elec4.mat
end
