function [percentage_1,percentage_2,percentage_3] = post_process_percentage(montage_coupled)
row_number = length(find(montage_coupled(:,3))); % 获得行数
if row_number == 0
    row_number = 1;
end
percentage_1 = montage_coupled(row_number,3)/montage_coupled(1,3); % Other中E>0.2V/m的小四面体个数
percentage_2 = montage_coupled(row_number,4)/montage_coupled(1,4); % ratio
percentage_3 = montage_coupled(row_number,5)/montage_coupled(1,5); % ROI中E>0.2V/m的小四面体个数
end