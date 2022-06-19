subject_range = 1:10;
edges_of_hist_ROI_and_hist_Other = [0 0:0.01:0.6 0.6]; % 直方图的划分
edges_of_hist_distance = [0 0:5:100 100]; % 直方图的划分

% zeros
hist_Other_start_normalization = zeros(length(subject_range),length(edges_of_hist_ROI_and_hist_Other)-3);
hist_Other_end_normalization = zeros(length(subject_range),length(edges_of_hist_ROI_and_hist_Other)-3);
hist_Other_subtraction_normalization = zeros(length(subject_range),length(edges_of_hist_ROI_and_hist_Other)-3);

hist_ROI_start_normalization = zeros(length(subject_range),length(edges_of_hist_ROI_and_hist_Other)-3);
hist_ROI_end_normalization = zeros(length(subject_range),length(edges_of_hist_ROI_and_hist_Other)-3);
hist_ROI_subtraction_normalization = zeros(length(subject_range),length(edges_of_hist_ROI_and_hist_Other)-3);

hist_distance_start_normalization = zeros(length(subject_range),length(edges_of_hist_distance)-3);
hist_distance_end_normalization = zeros(length(subject_range),length(edges_of_hist_distance)-3);
hist_distance_subtraction_normalization = zeros(length(subject_range),length(edges_of_hist_distance)-3);

for i = subject_range
    
    % set directory
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i); % set [dataRoot,subMark,simMark] for different subjects
    directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
    
    % histogram of Other
    load(fullfile(directory_of_cfg,'hist_Other_start.mat'),'hist_Other_start');
    temp = hist_Other_start/sum(hist_Other_start);
    hist_Other_start_normalization(i,:) = temp(1,2:(length(hist_Other_start)-1));
    load(fullfile(directory_of_cfg,'hist_Other_end.mat'),'hist_Other_end');
    temp = hist_Other_end/sum(hist_Other_end);
    hist_Other_end_normalization(i,:) = temp(1,2:(length(hist_Other_end)-1));
    hist_Other_subtraction_normalization(i,:) = hist_Other_end_normalization(i,:) - hist_Other_start_normalization(i,:);
    
    % histogram of ROI
    load(fullfile(directory_of_cfg,'hist_ROI_start.mat'),'hist_ROI_start');
    temp = hist_ROI_start/sum(hist_ROI_start);
    hist_ROI_start_normalization(i,:) = temp(1,2:(length(hist_ROI_start)-1));
    load(fullfile(directory_of_cfg,'hist_ROI_end.mat'),'hist_ROI_end');
    temp = hist_ROI_end/sum(hist_ROI_end);
    hist_ROI_end_normalization(i,:) = temp(1,2:(length(hist_ROI_end)-1));
    hist_ROI_subtraction_normalization(i,:) = hist_ROI_end_normalization(i,:) - hist_ROI_start_normalization(i,:);
    
    % histogram of distance
    load(fullfile(directory_of_cfg,'hist_distance_start.mat'),'hist_distance_start');
    hist_distance_start_normalization(i,:) = hist_distance_start(1,2:(length(hist_distance_start)-1));
    load(fullfile(directory_of_cfg,'hist_distance_end.mat'),'hist_distance_end');
    hist_distance_end_normalization(i,:) = hist_distance_end(1,2:(length(hist_distance_end)-1));
    hist_distance_subtraction_normalization(i,:) = hist_distance_end_normalization(i,:) - hist_distance_start_normalization(i,:);
    
end

% average
hist_Other_subtraction_normalization_average = mean(hist_Other_subtraction_normalization);
hist_ROI_subtraction_normalization_average = mean(hist_ROI_subtraction_normalization);
hist_distance_subtraction_normalization_average = mean(hist_distance_subtraction_normalization);
figure(1);
bar(0:0.01:0.59,hist_Other_subtraction_normalization_average);
figure(2);
bar(0:0.01:0.59,hist_ROI_subtraction_normalization_average);
figure(3);
bar(0:5:95,hist_distance_subtraction_normalization_average);