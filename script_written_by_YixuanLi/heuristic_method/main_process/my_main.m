%% often change
subject_range = [15]; % 被试范围
montage_chosen = [1]; % 选哪个montage当seed
montage_number = 10; % 最后选出多少个电极，正式操作时选10
penalty_coefficient_range = [1.5]; % 惩罚系数的范围，正式操作时选[1.5:0.5:4 5:1:10 12:2:20 50 100]
global n_alternative;
n_alternative = 100; % 每次惩罚后选前多少名作为备选montage，正式操作时选100
global montage_number_threshold;
montage_number_threshold = 1*10^5; % 电极组合的阈值

%% not often change
switch_screen_criterion = 1; % 筛选标准1：在备选montage中，选n下降得最多的作为新montage
global edges_of_hist_ROI_and_hist_Other;
edges_of_hist_ROI_and_hist_Other = [0 0:0.01:0.6 0.6]; % 直方图的划分
global edges_of_hist_distance;
edges_of_hist_distance = [0 0:5:100 100]; % 直方图的划分
global switch_adding_proportion;
switch_adding_proportion = 1;  % 添加比例：1代表不用k，2代表用k
global count_of_figure;
count_of_figure = 1;

%% main process
for i = subject_range        
    %% start time
    start = datestr(now);
    
    %% set directory
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i); % set [dataRoot,subMark,simMark] for different subjects
    directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
    
    %% core
    find_alternative_and_choose(dataRoot,subMark,simMark,montage_chosen,montage_number,penalty_coefficient_range,switch_screen_criterion); % find alternatives and choose one montage from these alternatives
    
    %% end time
    fprintf("For number %d subject:\n",i);
    disp(['Start time : ' start])
    disp(['End time : ' datestr(now)])
    
end