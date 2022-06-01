function hlink = compareElec_thres(datapath,ROI,method_ROI,method_Cortex,LF,thres_method,thres,saveFlag,closeFlag)
% thres_method: 1--使用ROI最大值乘以 0-1 之间的 thres 系数作为阈值
%               2--使用给定的 thres 数值作为阈值
%% read data
elecNum = [4,6,8];
N = length(elecNum);
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
path4save = fullfile(path4saveLF,['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
U = cell(N,1);
gray_matter0 = cell(N,1);
StimProtocol0 = cell(N,1);
Area_ROI = zeros(N,length(thres));
Area_Cortex = zeros(N,length(thres));
Dispersion = zeros(N,length(thres));
hlink = cell(length(thres),1);
%% prepare data
for i = 1:N
    S = load(fullfile(path4save,['elec' num2str(elecNum(i)) '.mat']),['U' num2str(elecNum(i)) 'm']);
    U{i} = eval(['S.U' num2str(elecNum(i)) 'm']);
    [StimProtocol0{i},gray_matter0{i}] = Elec_Parameter(U{i},LF);
end
for i_thres = 1:length(thres)
    %% plot 1
    figure('WindowState','maximized');
    a1 = 1;
    a2 = 3;
    ax = cell(N,1);
    % colorbar on;
    for i = 1:3
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
        [gray_matter1] = Cortex_thres(gray_matter0{i},Thres,1234,setdiff(unique(gray_matter0{i}.triangle_regions),1234),[]);
        [Area_ROI(i,i_thres),Area_Cortex(i,i_thres),~,Dispersion(i,i_thres)] = showROIThres(gray_matter1,9001,9002,[]);
        title([num2str(elecNum(i)) ' electrodes']);
        axis equal;
    end
    axC = axes('Position',[0.1367 0.2236 0.7617 0.0273]);
    title(['Threshold = ' S_thres],'FontSize',15);
    axis off
    hlink{i_thres} = linkprop([ax{:}],{'CameraPosition','CameraUpVector'});
    if saveFlag
        saveas(gcf,fullfile(path4save,['DifElec_Suprathreshold areas with Thres_' S_thres '_' num2str(thres_method) '.fig']));
    end
    %% plot 2 : ROI & Cortex
    h2 = figure;
    elecNum_mark = 1:N;
    plot(elecNum_mark,Area_ROI/Area_ROI(1),'-s','Color',[238,118,0]./255,'LineWidth',2,'MarkerFaceColor','auto');
    hold on;
    plot(elecNum_mark,Area_Cortex/Area_Cortex(1),'-s','Color',[153,50,204]./255,'LineWidth',2,'MarkerFaceColor','auto');
    hold off;
    xlim([0.5 N+0.5]);
    ylim([0.85 max(Area_Cortex/Area_Cortex(1))+0.15]);
    ylabel('Suprathreshold brain area proportion','FontSize',12,'LineWidth',2);
    xlabel("Electrode number",'FontSize',12,'LineWidth',2);
    title(['Electrode number effect above threshold ' num2str(thres*100) '%']);
%     hl = legend('ROI','Cortex');
%     set(hl,'FontSize',12);
    set(gca,'xtick',elecNum_mark);
    Xticklabel = cell(N,1);
    for i = 1:N
            Xticklabel{i} = num2str(elecNum(i));
    end
    set(gca,'xticklabel',Xticklabel);
    %% plot 3 : dispersion in Cortex
%     h3 = figure;
%     plot([4 6 8],Dispersion,'-s','LineWidth',2,'MarkerFaceColor','auto');
%     ylabel('Dispersion of suprathreshold nodes','FontSize',12,'LineWidth',2);
%     %     xlabel('Num of elec','FontSize',12,'LineWidth',2);
%     set(gca,'xtick',[4 6 8]);
%     set(gca,'xticklabel',{'4 elec','6 elec','8 elec'});
%     sgtitle(['Threshold = ' S_thres]);
    if saveFlag
        saveas(gcf,fullfile(path4save,['DifElec_Suprathreshold brain area proportion with Thres_' S_thres '_' num2str(thres_method) '.tif']));
    end
end
if closeFlag
    close all;
end
end

