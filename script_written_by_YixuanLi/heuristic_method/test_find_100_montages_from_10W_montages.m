% ranking number of subject
ranking_number_of_subject = 1;
[dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(ranking_number_of_subject);

% upload cfg
directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
[cfg,elec4] = upload_cfg_and_elec4(directory); 

% main process
n_alternative = 10^(4)*2;
montage_alternative = zeros(n_alternative,8); % 提前分配空间以提高速度
penalty_coefficient = cfg.Avoid.coef;
load(fullfile(directory,'elec4_Exhaustion.mat'),'T');
directory_elec4_Exhaustion_PenaltyCoefficient1 = [directory '\elec4_Exhaustion_PenaltyCoefficient1.mat'];
tic;
for j = 1:n_alternative
    electrode_wanted = [T.elecA(j,1) T.elecA(j,2) T.elecB(j,1) T.elecB(j,2)]; % find the wanted montage
    current_wanted =  T.cuA(j,1);
    ranking_initial = find_the_wanted_electrode(directory_elec4_Exhaustion_PenaltyCoefficient1,electrode_wanted,current_wanted);
    montage_alternative(j,1) = penalty_coefficient;
    montage_alternative(j,2:5) = electrode_wanted;
    montage_alternative(j,6) = current_wanted;
    montage_alternative(j,7) = ranking_initial;
    montage_alternative(j,8) = ranking_initial - j; % ranking_initial - j 最大的那个上升得最快
end
montage_alternative_descend = sortrows(montage_alternative,8,'descend');
toc; 

% result:
% 时间复杂度为O(n)，准确地说是1.4n
% 10^2 2s
% 10^3 28s
% 10^4 407s