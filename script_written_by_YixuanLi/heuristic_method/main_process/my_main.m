%% pre process
subject_range = 1:10; % 被试范围
montage_chosen = [1]; % 选哪个montage当seed
montage_number = 6; % 最后选出多少个电极
penalty_coefficient_range = [2:1:5 6:2:10 12:4:20 50 100]; % 惩罚系数的范围

global montage_number_threshold;
montage_number_threshold = 1*10^5; % 电极组合的阈值

global n_alternative;
n_alternative = 100; % 每次惩罚后选前多少名作为备选montage，正式操作时选100

switch_screen_criterion = 1; % 1代表在备选montage中，选n下降得最多的作为新montage

global edges_of_hist_ROI_and_hist_Other;
edges_of_hist_ROI_and_hist_Other = [0 0:0.01:0.6 0.6]; % 直方图的划分

global edges_of_hist_distance;
edges_of_hist_distance = [0 0:5:100 100]; % 直方图的划分

global switch_adding_proportion;
switch_adding_proportion = 1;  % 1代表每个montage的权重相同，2代表每个montage的权重不同

global count_of_figure;
count_of_figure = 1; % figure的计数

%% main process
for i = subject_range        
    %% start time
    start = datestr(now); 
    
    %% core
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i);
    find_alternative_and_choose(dataRoot,subMark,simMark,montage_chosen,montage_number,penalty_coefficient_range,switch_screen_criterion); % find alternatives and choose one montage from these alternatives
    
    %% end time
    fprintf("For number %d subject:\n",i);
    disp(['Start time : ' start])
    disp(['End time : ' datestr(now)])
    
end