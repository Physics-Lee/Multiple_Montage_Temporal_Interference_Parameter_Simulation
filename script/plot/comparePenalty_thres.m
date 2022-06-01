function hlink = comparePenalty_thres(datapath,ROI,method_ROI,method_Cortex,elecNum,Penalty_coef,thres_method,thres,saveFlag,closeFlag)
% thres_method: 1--使用ROI最大值乘以 0-1 之间的 thres 系数作为阈值
%               2--使用给定的 thres 数值作为阈值
%% read data
N = length(Penalty_coef);
U = cell(N,1);
gray_matter0 = cell(N,1);
StimProtocol0 = cell(N,1);
Area_ROI = zeros(N,length(thres));
Area_Cortex = zeros(N,length(thres));
Area_Penalty = zeros(N,length(thres));
hlink = cell(length(thres),1);
path4saveFig = fullfile(datapath,'Result',ROI.name);
%% prepare data
for i = 1:N
    path4saveLF = fullfile(datapath,'Result',ROI.name,['P_' num2str(Penalty_coef(1,i))]);
    path4save = fullfile(path4saveLF,['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
    if ~(exist(path4saveLF,'dir') && exist(path4save,'dir'))
        error('Not correct path!')
    end
    LFfile = fullfile(path4saveLF,'LF.mat');
    load(LFfile);
    S = load(fullfile(path4save,['elec' num2str(elecNum) '.mat']),['U' num2str(elecNum) 'm']);
    U{i} = eval(['S.U' num2str(elecNum) 'm']);
    [StimProtocol0{i},gray_matter0{i}] = Elec_Parameter(U{i},LF);
end
for i_thres = 1:length(thres)
    %% plot 1
    figure('WindowState','maximized');
    a1 = 2;
    a2 = 2;
    ax = cell(N,1);
    for i = 1:N
        if thres_method == 1
            Thres = thres(i_thres)*max(StimProtocol0{i}.TI_ROI);
            S_thres =  num2str(thres(i_thres));
        elseif thres_method == 2
            Thres = thres(i_thres);
            S_thres = num2str(thres(i_thres));
        else
            disp('Wrong thres_method! Please check...');
            return;
        end
        ax{i} = subplot(a1,a2,i);
        if(i/a2>1)
            ax{i}.Position(2) = ax{i}.Position(2)+0.1*(floor((i-1)/a2));
        end
        [gray_matter1] = Cortex_thres(gray_matter0{i},Thres,1234,setdiff(unique(gray_matter0{i}.triangle_regions),[1234 666]),666);
        [Area_ROI(i,i_thres),Area_Cortex(i,i_thres),Area_Penalty(i,i_thres),~] = showROIThres(gray_matter1,9001,9002,9003);
        title(['p = ' num2str(Penalty_coef(i))]);
        axis equal;
    end
    %%
    axC = axes('Position',[0.1367 0.2236 0.7617 0.0273]);
    title(['Threshold = ' S_thres],'FontSize',15);
    axis off
    %%
    hlink{i_thres} = linkprop([ax{:}],{'CameraPosition','CameraUpVector'});
    if saveFlag
        saveas(gcf,fullfile(path4saveFig,['DifPenalty_Suprathreshold areas with Thres_' S_thres '_' num2str(thres_method) '.fig']));
    end
    
    %% plot 2 : ROI & Cortex
    h2 = figure;
    Penaltycoef_mark = 1:N;
    plot(Penaltycoef_mark,Area_ROI/Area_ROI(1),'-s','LineWidth',2,'Color',[238,118,0]./255,'MarkerFaceColor','auto');
    hold on;
    plot(Penaltycoef_mark,Area_Penalty/Area_Penalty(1),'-s','LineWidth',2,'Color',[0,139,139]./255,'MarkerFaceColor','auto');
    hold on;
    plot(Penaltycoef_mark,Area_Cortex/Area_Cortex(1),'-s','LineWidth',2,'Color',[153,50,204]./255,'MarkerFaceColor','auto');
    hold off;
    xlim([0.5 N+0.5]);
    ylim([Area_Penalty(N)/Area_Penalty(1)-0.2 max(Area_Cortex/Area_Cortex(1))+0.5]);
    ylabel('Suprathreshold brain area proportion','FontSize',12,'LineWidth',2);
    xlabel("Penalty coefficient",'FontSize',12,'LineWidth',2);
    title(['Penalty effect above threshold ' num2str(thres*100) '%']);
    h1 = legend('Target','Penalty','Irrelevant');
    set(h1,'FontSize',12);
    set(gca,'xtick',Penaltycoef_mark);
    Xticklabel = cell(N,1);
    for i = 1:N
             Xticklabel{i} = num2str(Penalty_coef(i));
    end
    set(gca,'xticklabel',Xticklabel);
    
    %     subplot(1,2,2);
    %     plot([Penalty_coef],Dispersion,'-s','LineWidth',2,'MarkerFaceColor','auto');
    %     ylabel('Dispersion of suprathreshold nodes','FontSize',12,'LineWidth',2);
    %     %     xlabel('Num of elec','FontSize',12,'LineWidth',2);
    %     set(gca,'xtick',[Penalty_coef]);
    %     set(gca,'xticklabel',Xticklabel);
    %     sgtitle(['Threshold = ' S_thres]);
    if saveFlag
        saveas(gcf,fullfile(path4saveFig,['DifPenalty_Suprathreshold nodes with Thres_' S_thres '_' num2str(thres_method) '.tif']));
    end
    
end
if closeFlag
    close all
end



