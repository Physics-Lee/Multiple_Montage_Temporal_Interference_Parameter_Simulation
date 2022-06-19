subject_range = 1:10;
for i = subject_range
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i);
    directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
    load(fullfile(directory_of_cfg,'montage_coupled.mat'),'montage_coupled');
    [row_number,~] = size(montage_coupled); % 获得行数
    percentage_1(i,1) = montage_coupled(row_number,3)/montage_coupled(1,3); % Other中E>0.2V/m的小四面体个数
    percentage_2(i,1) = montage_coupled(row_number,4)/montage_coupled(1,4); % ratio
    percentage_3(i,1) = montage_coupled(row_number,5)/montage_coupled(1,5); % ROI中E>0.2V/m的小四面体个数
end
percentage_1_average = mean(percentage_1);
percentage_2_average = mean(percentage_2);
percentage_3_average = mean(percentage_3);