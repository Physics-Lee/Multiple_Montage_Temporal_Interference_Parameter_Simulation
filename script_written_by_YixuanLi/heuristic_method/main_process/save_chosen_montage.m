function [montage_coupled,row_number] = save_chosen_montage(montage_coupled,row_number,n_Other_pre,ratio_pre,n_ROI_pre,montage_alternative,row_index_of_chosen_montage)

if row_number == 1
    montage_coupled(row_number,1) = row_number - 1; % 代表第几次惩罚
    montage_coupled(row_number,2) = 1; % 代表montage的ranking
    montage_coupled(row_number,3) = n_Other_pre; % 代表Other中超过E_threshold的小四面体个数
    montage_coupled(row_number,4) = ratio_pre; % 代表ratio
    montage_coupled(row_number,5) = n_ROI_pre; % 代表ROI中超过E_threshold的小四面体个数
    montage_coupled(row_number,6) = 0; % 代表惩罚系数
    montage_coupled(row_number,7) = 0; % k：前面所有电极占比k/10，这个电极占比(10-k)/10
    row_number = row_number + 1;
end

if row_number >= 2
    montage_coupled(row_number,1) = row_number - 1; % 代表第几次惩罚
    montage_coupled(row_number,2) = montage_alternative(row_index_of_chosen_montage,7); % 代表montage的ranking
    montage_coupled(row_number,3) = montage_alternative(row_index_of_chosen_montage,9); % 代表Other中超过E_threshold的小四面体个数
    montage_coupled(row_number,4) = montage_alternative(row_index_of_chosen_montage,10); % 代表ratio
    montage_coupled(row_number,5) = montage_alternative(row_index_of_chosen_montage,8); % 代表ROI中超过E_threshold的小四面体个数
    montage_coupled(row_number,6) = montage_alternative(row_index_of_chosen_montage,1); % 代表惩罚系数
    montage_coupled(row_number,7) = montage_alternative(row_index_of_chosen_montage,11); % k：前面所有电极占比k/10，这个电极占比(10-k)/10
    row_number = row_number + 1;
end

end