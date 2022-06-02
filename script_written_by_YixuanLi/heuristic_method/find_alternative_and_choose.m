function find_alternative_and_choose(dataRoot,subMark,simMark,montage_chosen,montage_number,penalty_coefficient_range,switch_screen_criterion)
%% pre process
% set directory
directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark);

% upload cfg.mat and elec4.mat
[cfg,elec4] = upload_cfg_and_elec4(directory);

% upload hdf5
hdf5 = upload_hdf5(cfg);

% upload E & volume & mesh & N by prepare_LF
[input.E,input.volume,~,mesh] = temp_prepare_LF(dataRoot,subMark,cfg);
input.N = size(input.E,1);

% upload ROI_idx by TargetRegionIdx
ROI_idx = TargetRegionIdx(dataRoot,subMark,mesh,cfg.ROI,cfg.type);

% set E_threshold
E_threshold = 0.2;

% easy
count_main_round = 1; % main round 的计数
montage_coupled = zeros(1,7);
row_number = 1; % montage_coupled的行数
flag_break = 0; % 最后一个montage要用

while(1)    
    fprintf('-----------------------------------------main round %d-----------------------------------------\n',count_main_round);
    
    % calculate ELf_average of all the previous montages
    Elf_average = calculate_Elf_average_of_previous_montages(montage_chosen,ROI_idx,input,elec4);
    
    % get_ranking_list_of_200w_tet: x轴为距离，y轴为小四面体个数
    ranking_list_of_200w_tet_descend = get_ranking_list_of_200w_tet(hdf5,Elf_average,ROI_idx);
    
    % get MNI coordinates of the centers of tetrahedron above E threshold
    center_of_tet_above_E_threshold_MNI_coord = subject2mni(hdf5,ranking_list_of_200w_tet_descend,cfg,Elf_average,E_threshold);
    
    % find the ranking near E_threshold
    [n_ROI_pre,n_Other_pre] = find_the_ranking_near_threshold(Elf_average,E_threshold,ROI_idx);
    
    % calculate average ratio
    ratio_pre = heuristic_calculate_average_ratio(input,Elf_average,ROI_idx); 
    
    % histogram of ROI and Other: x轴为电场强度，y轴为小四面体个数
    histogram_ROI_Other(Elf_average,ROI_idx,count_main_round,flag_break,directory);
    
    % histogram of distance
    distance_ascend = histogram_distance(cfg,ranking_list_of_200w_tet_descend,center_of_tet_above_E_threshold_MNI_coord,count_main_round,flag_break,directory);
    
    % draw sphere in MNI space
    draw_sphere_in_MNI_space(center_of_tet_above_E_threshold_MNI_coord,cfg,'red','+');    
    
    % calculate and save avoid_idx
    avoid_idx = calculate_avoid_idx(cfg,Elf_average,E_threshold,ROI_idx,distance_ascend,center_of_tet_above_E_threshold_MNI_coord);
    save(fullfile(dataRoot,subMark,'TI_sim_result',simMark,'avoid_idx.mat'),'avoid_idx'); % prepare_LF要用

    %% change penalty coefficient to find alternative montages
    montage_alternative = change_penalty_coefficient(cfg,Elf_average,montage_chosen,input,elec4,ROI_idx,E_threshold,penalty_coefficient_range);
    fprintf('The alternative montages will be showed below:\n');
    format rational;
    disp(montage_alternative);
    fprintf('I will choose one montage from these alternative montages\n');
    
    %% choose a new montage from the alternatives
    switch switch_screen_criterion
        case 1
            [montage_chosen,row_index_of_chosen_montage,flag_break] = criterion_1(montage_chosen,montage_alternative,n_Other_pre);
        case 2
            n_drop = 1;
            [montage_chosen,row_index_of_chosen_montage,flag_break] = criterion_2(montage_chosen,montage_alternative,n_Other_pre,ratio_pre,n_drop);
        case 3
            n_drop = 2000;
            [montage_chosen,row_index_of_chosen_montage,flag_break] = criterion_2(montage_chosen,montage_alternative,n_Other_pre,ratio_pre,n_drop);
    end
    
    %% Whether the loop termination condition is met   
    if flag_break == 1
        fprintf('\n---------------------------------Other中E>E_threshold的小四面体个数没有下降！！！---------------------------------\n');
        break; % 第一种break：无关脑区中小四面体个数不再下降
    end
    
    % save chosen montage to montage_coupled
    [montage_coupled,row_number] = save_chosen_montage(montage_coupled,row_number,n_Other_pre,ratio_pre,n_ROI_pre,montage_alternative,row_index_of_chosen_montage);
    save(fullfile(directory,'montage_coupled.mat'),'montage_coupled');
    fprintf('The coupled montages will be showed below:\n');
    disp(montage_coupled);
    
    % if the montage number meets the requirement, then break
    if length(montage_chosen) == montage_number
        fprintf('\n--------------------------------------------电极数目已经达到要求！！！--------------------------------------------\n');        
        flag_break = 1;
        break; % 第二种break：电极数目已经达到要求
    end
    count_main_round = count_main_round + 1;
end

%% post process：用break跳出while之后，再计算一次hist_ROI、hist_Other、hist_distance并且保存

% calculate the average value of all the previous montages' Elf
Elf_average = calculate_Elf_average_of_previous_montages(montage_chosen,ROI_idx,input,elec4);

% histogram of ROI and Other: x轴为电场强度，y轴为小四面体个数
count_main_round = count_main_round + 1;
histogram_ROI_Other(Elf_average,ROI_idx,count_main_round,flag_break,directory);

% histogram of distance
histogram_distance(cfg,ranking_list_of_200w_tet_descend,center_of_tet_above_E_threshold_MNI_coord,count_main_round,flag_break,directory);

close all;

end