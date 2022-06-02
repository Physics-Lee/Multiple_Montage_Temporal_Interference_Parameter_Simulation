function [cfg,elec4] = upload_cfg_and_elec4(directory)
load(fullfile(directory,'cfg.mat'),'cfg'); % upload cfg.mat % In this way, MATLAB won't warn me.
elec4 = load(fullfile(directory,'elec4_Exhaustion_PenaltyCoefficient1.mat')); % upload elec4.mat
end
