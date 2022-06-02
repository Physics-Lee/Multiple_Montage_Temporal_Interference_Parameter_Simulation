function montage_alternative = change_penalty_coefficient(cfg,Elf,scheme,input,elec4,ROI_idx,E_threshold,penalty_coefficient_range)
%% change penalty coefficient
dataRoot = cfg.dataRoot;
subMark = cfg.subMark;
simMark = cfg.simMark;
count_i = 1;
row_number = 1;
montage_alternative = NaN;
global n_alternative;
global montage_number_threshold;
for i = penalty_coefficient_range
    fprintf('--------------------------------------------------round %d--------------------------------------------------\n',count_i);
    fprintf('-----------------------------------------penalty coefficient == %.1f----------------------------------------\n',i);
    cfg.Avoid.coef = i;
    temp = OpenTIPS(cfg,montage_number_threshold); % 这一行是我的代码和张为师兄的代码的接口
    directory_elec4_Exhaustion_PenaltyCoefficient1 = [fullfile(dataRoot,subMark,'TI_sim_result',simMark) '\elec4_Exhaustion_PenaltyCoefficient1.mat'];
    for j = 1:n_alternative
        electrode_wanted = [temp.elecA(j,1) temp.elecA(j,2) temp.elecB(j,1) temp.elecB(j,2)]; % find the wanted montage
        current_wanted =  temp.cuA(j,1);
        ranking_initial = find_the_wanted_electrode(directory_elec4_Exhaustion_PenaltyCoefficient1,electrode_wanted,current_wanted);
        montage_alternative(row_number,1) = i;
        montage_alternative(row_number,2:5) = electrode_wanted;
        montage_alternative(row_number,6) = current_wanted;
        montage_alternative(row_number,7) = ranking_initial;
        row_number = row_number + 1;
    end
    count_i = count_i + 1;
end

%% 给penalty_coefficient_and_ranking加上第8、9、10列,分别为ROI中超过E_threshold的小四面体个数、ROI中超过E_threshold的小四面体个数、ratio

% 为省去循环中的判断，把i=1单独拿出来
i = 1;
montage_alternative = calculate_n1_n2_ratio_of_each_new_scheme(montage_alternative,i,input,elec4,scheme,Elf,E_threshold,ROI_idx);

% for循环
[row_number,~] = size(montage_alternative);
for i = 2:row_number
    if find(~(montage_alternative(1:i-1,7) - montage_alternative(i,7)))
        i_pre = find(~(montage_alternative(1:i-1,7) - montage_alternative(i,7)));
        i_first = i_pre(1);
        montage_alternative(i,2:11) = montage_alternative(i_first,2:11);
        continue
    end
    montage_alternative = calculate_n1_n2_ratio_of_each_new_scheme(montage_alternative,i,input,elec4,scheme,Elf,E_threshold,ROI_idx);
end

% 算一下已有的scheme会不会有更好的效果
for i = row_number + 1:row_number + length(scheme)
    montage_alternative(i,7) = scheme(i-row_number); % 把scheme加到penalty_coefficient_and_ranking的第七列
    if find(~(montage_alternative(1:i-1,7) - montage_alternative(i,7)))
        i_pre = find(~(montage_alternative(1:i-1,7) - montage_alternative(i,7)));
        i_first = i_pre(1);
        montage_alternative(i,2:11) = montage_alternative(i_first,2:11);
        continue
    end
    montage_alternative = calculate_n1_n2_ratio_of_each_new_scheme(montage_alternative,i,input,elec4,scheme,Elf,E_threshold,ROI_idx);
end

end