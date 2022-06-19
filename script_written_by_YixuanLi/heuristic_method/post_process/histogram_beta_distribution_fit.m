subject_range = 1:10; % 被试范围

for i = subject_range
    
    fprintf('i = %d\n',i);
    
    %% beta distribution fit for pre
    
    % easy
    [dataRoot,subMark,simMark] = set_dataRoot_subMark_simMark(i); % set [dataRoot,subMark,simMark] for different subjects
    directory_of_cfg = fullfile(dataRoot,subMark,'TI_sim_result',simMark); % set directory
    [cfg,elec4] = upload_cfg_and_elec4(directory_of_cfg); % input cfg.mat and elec4.mat
    [input.E,input.volume,~,mesh] = temp_prepare_LF(dataRoot,subMark,cfg); % input E & volume & mesh & N by prepare_LF
    input.N = size(input.E,1);
    ROI_idx = TargetRegionIdx(dataRoot,subMark,mesh,cfg.ROI,cfg.type); % input ROI_idx
    
    % montage_chosen
    montage_chosen = 1;
    
    % calculate the average value of all the previous montages' Elf
    Elf_temp_pre = zeros(length(ROI_idx),length(montage_chosen)); % 预先分配空间以提高速度
    for j = 1:length(montage_chosen)
        fprintf('i = %d,j = %d\n',i,j);
        Elf_temp_pre(:,j) = input_Elf(input,elec4,montage_chosen(j)); % Elf_temp的每一列是之前某个montage的ELf
    end
    Elf = mean(Elf_temp_pre,2); % 对Elf_temp按行求平均
    Elf_Other = Elf(~ROI_idx); % Other中的El
    
    % histfit
%     figure(i);
%     histfit(Elf_Other,100,'beta');
%     saveas(figure(i),['D:\' 'beta_distribution_pre_' num2str(i) '.png']);
    
    % fitdist
    beta_distribution = fitdist(Elf_Other,'beta');
    a_pre(i,1) = beta_distribution.a;
    b_pre(i,1) = beta_distribution.b;
%     save(['D:\' 'beta_distribution_pre_' num2str(i) '.mat'],'beta_distribution');

    %% beta distribution fit for post
    
    % montage_chosen
    load(fullfile(directory_of_cfg,'montage_coupled.mat'),'montage_coupled'); % input montage_coupled
    montage_chosen = montage_coupled(:,2); % input montage_coupled
    
    % calculate the average value of all the previous montages' Elf
    Elf_temp_post = zeros(length(ROI_idx),length(montage_chosen)); % 预先分配空间以提高速度
    for j = 1:length(montage_chosen)
        fprintf('i = %d,j = %d\n',i,j);
        Elf_temp_post(:,j) = input_Elf(input,elec4,montage_chosen(j)); % Elf_temp的每一列是之前某个montage的ELf
    end
    Elf = mean(Elf_temp_post,2); % 对Elf_temp按行求平均
    Elf_Other = Elf(~ROI_idx); % Other中的El
    
    % histfit
%     figure(i);
%     histfit(Elf_Other,100,'beta');
%     saveas(figure(i),['D:\' 'beta_distribution_post_' num2str(i) '.png']);
    
    % fitdist
    beta_distribution = fitdist(Elf_Other,'beta');
    a_post(i,1) = beta_distribution.a;
    b_post(i,1) = beta_distribution.b;
%     save(['D:\' 'beta_distribution_post_' num2str(i) '.mat'],'beta_distribution');
    
end

%% pair t test
[h_a,p_a] = ttest(a_pre,a_post);
[h_b,p_b] = ttest(b_pre,b_post);

figure(1)
scatter(subject_range,a_pre,50,'filled','blue','o');
hold on;
scatter(subject_range,a_post,50,'filled','red','o');
xlabel('subject number');
ylabel('a');
legend('a pre','a post');
title('若假定a服从均值等于零且方差未知的正态分布，则p值为',p_a);

figure(2)
scatter(subject_range,b_pre,50,'filled','blue','o');
hold on;
scatter(subject_range,b_post,50,'filled','red','o');
xlabel('subject number');
ylabel('b');
legend('b pre','b post');
title('若假定b服从均值等于零且方差未知的正态分布，则p值为',p_b);