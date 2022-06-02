percentage = zeros(length(subject_range),3);
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
    %% handle 011 subject specially
    if i == 11
        continue % 我可以把011号被试的montage个数从5.9W加到10W，但是这样可能会导致011号被试的ratio和其他人很不一样
    end
    
    %% set directory
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i); % set [dataRoot,subMark,simMark] for different subjects
    directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
    
    %% post process: percentage
    load(fullfile(directory,'montage_coupled.mat'),'montage_coupled');
    [percentage(i,1),percentage(i,2),percentage(i,3)] = post_process_percentage(montage_coupled); % 第一列为Other，第二列为Ratio，第三列为ROI
    
    %% post process: histogram of Other
    load(fullfile(directory,'hist_Other_start.mat'),'hist_Other_start');
    temp = hist_Other_start/sum(hist_Other_start);
    hist_Other_start_normalization(i,:) = temp(1,2:(length(hist_Other_start)-1));
    load(fullfile(directory,'hist_Other_end.mat'),'hist_Other_end');
    temp = hist_Other_end/sum(hist_Other_end);
    hist_Other_end_normalization(i,:) = temp(1,2:(length(hist_Other_end)-1));
    hist_Other_subtraction_normalization(i,:) = hist_Other_end_normalization(i,:) - hist_Other_start_normalization(i,:);
    
    %% post process: histogram of ROI
    load(fullfile(directory,'hist_ROI_start.mat'),'hist_ROI_start');
    temp = hist_ROI_start/sum(hist_ROI_start);
    hist_ROI_start_normalization(i,:) = temp(1,2:(length(hist_ROI_start)-1));
    load(fullfile(directory,'hist_ROI_end.mat'),'hist_ROI_end');
    temp = hist_ROI_end/sum(hist_ROI_end);
    hist_ROI_end_normalization(i,:) = temp(1,2:(length(hist_ROI_end)-1));
    hist_ROI_subtraction_normalization(i,:) = hist_ROI_end_normalization(i,:) - hist_ROI_start_normalization(i,:);
    
    %% post process: histogram of distance
    load(fullfile(directory,'hist_distance_start.mat'),'hist_distance_start');
    temp = hist_distance_start/sum(hist_distance_start);
    hist_distance_start_normalization(i,:) = temp(1,2:(length(hist_distance_start)-1));
    load(fullfile(directory,'hist_distance_end.mat'),'hist_distance_end');
    temp = hist_distance_end/sum(hist_distance_end);
    hist_distance_end_normalization(i,:) = temp(1,2:(length(hist_distance_end)-1));
    hist_distance_subtraction_normalization(i,:) = hist_distance_end_normalization(i,:) - hist_distance_start_normalization(i,:);
end