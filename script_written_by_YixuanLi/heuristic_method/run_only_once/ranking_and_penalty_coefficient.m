for ranking_number_of_subject = 1
    % unload cfg
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(ranking_number_of_subject);
    directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
    [cfg,~] = upload_cfg_and_elec4(directory); 

    % main process
    tic;
    penalty_coefficient_range = [100:100:1000];
    penalty_coefficient_range_log = 2:10;
    penalty_coefficient_range = 10.^penalty_coefficient_range_log;
    n_alternative = 100;
    montage_number_threshold = 1*10^5;
    ranking_initial_temp = zeros(1,n_alternative);
    ranking_initial = zeros(26,length(penalty_coefficient_range));
    count = 1;
    for i = penalty_coefficient_range
        cfg.Avoid.coef = i;
        load(fullfile(directory,['elec4_Exhaustion_PenaltyCoefficient_' num2str(i) '.mat']))
        directory_elec4_Exhaustion_PenaltyCoefficient1 = [fullfile(dataRoot,subMark,'TI_sim_result',simMark) '\elec4_Exhaustion_PenaltyCoefficient1.mat'];
        for j = 1:n_alternative
            electrode_wanted = [T.elecA(j,1) T.elecA(j,2) T.elecB(j,1) T.elecB(j,2)]; % find the wanted montage
            current_wanted =  T.cuA(j,1);
            ranking_initial_temp(1,j) = find_the_wanted_electrode(directory_elec4_Exhaustion_PenaltyCoefficient1,electrode_wanted,current_wanted);
        end
        ranking_initial(ranking_number_of_subject,count) = mean(ranking_initial_temp);
        count = count + 1;
    end
    
    % post process
    figure(1)
    plot(penalty_coefficient_range,ranking_initial(ranking_number_of_subject,:),'black-o');
    xlabel('penalty coefficient');
    ylabel('ranking initial');
    figure(2)
    plot(log(penalty_coefficient_range)/log(10),ranking_initial(ranking_number_of_subject,:),'black-o');
    xlabel('log(penalty coefficient)');
    ylabel('ranking initial');
    ylim([0,35000]);
    toc; 
end