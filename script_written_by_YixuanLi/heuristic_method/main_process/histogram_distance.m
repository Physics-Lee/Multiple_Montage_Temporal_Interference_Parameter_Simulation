function distance_ascend = histogram_distance(cfg,ranking_list_of_200w_tet_descend,center_of_tet_above_E_threshold_MNI_coord,count_main_round,flag_break,directory)

% 计算超过E_threshold的小四面体到ROI中心的欧几里得距离
center_of_ROI = cfg.ROI.table.CoordMNI;
number_of_tet_above_E_threshold = size(center_of_tet_above_E_threshold_MNI_coord,1);
distance = zeros(number_of_tet_above_E_threshold,1);
for j = 1:number_of_tet_above_E_threshold
    distance(j,1) = pdist([center_of_tet_above_E_threshold_MNI_coord(j,:);center_of_ROI],'euclidean');
end

% 在distance的第二列加上每个小四面体的编号
distance(:,2) = ranking_list_of_200w_tet_descend(1:number_of_tet_above_E_threshold,7);

% 升序排列，avoid_idx会
distance_ascend = sortrows(distance,1,'ascend');

% draw histogram
global count_of_figure;
figure(count_of_figure)
count_of_figure = count_of_figure + 1;
global edges_of_hist_distance;
h_distance = histogram(distance(:,1),edges_of_hist_distance);

% save
if count_main_round == 1
    hist_distance_start = h_distance.Values;
    save(fullfile(directory,'hist_distance_start.mat'),'hist_distance_start');
end

if flag_break == 1
    hist_distance_end = h_distance.Values;
    save(fullfile(directory,'hist_distance_end.mat'),'hist_distance_end');
end

end