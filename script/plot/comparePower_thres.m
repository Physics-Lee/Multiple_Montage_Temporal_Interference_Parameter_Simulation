function hlink = comparePower_thres(datapath,ROI,method_ROI,method_Cortex,LF,elecNum,thres_method,thres,saveFlag,closeFlag)
% thres_method: 1--使用ROI最大值乘以 0-1 之间的 thres 系数作为阈值
%               2--使用给定的 thres 数值作为阈值
%% read data
N = length(method_Cortex);
U = cell(N,1);
gray_matter0 = cell(N,1);
StimProtocol0 = cell(N,1);
Area_ROI = zeros(N,length(thres));
Area_Cortex = zeros(N,length(thres));
Dispersion = zeros(N,length(thres));
hlink = cell(length(thres),1);
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
for i = 1:N
    path4save = fullfile(path4saveLF,['R' num2str(method_ROI(i)) '_C' num2str(method_Cortex(i))]);
    S = load(fullfile(path4save,['elec' num2str(elecNum) '.mat']),['U' num2str(elecNum) 'm']);
    U{i} = eval(['S.U' num2str(elecNum) 'm']);
    [StimProtocol0{i},gray_matter0{i}] = Elec_Parameter(U{i},LF);
end

for i_thres = 1:length(thres)
    %% plot 1
    figure('WindowState','maximized');
    ax = cell(N,1);
    a1 = 2;
    a2 = 2;
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
        if(i>2)
            ax{i}.Position(2) = ax{i}.Position(2)+0.1;
        end
        [gray_matter1] = Cortex_thres(gray_matter0{i},Thres,1234,setdiff(unique(gray_matter0{i}.triangle_regions),1234),[]);
        [Area_ROI(i,i_thres),Area_Cortex(i,i_thres),~,Dispersion(i,i_thres)] = showROIThres(gray_matter1,9001,9002,[]);
        if method_Cortex(i)==0
            title('max')
        else
            title([num2str(method_Cortex(i)) ' power weighted average']);
        end
        axis equal;
    end
    axC = axes('Position',[0.1367 0.2236 0.7617 0.0273]);
    title(['Threshold = ' S_thres],'FontSize',15);
    axis off
    %%
    hlink{i_thres} = linkprop([ax{:}],{'CameraPosition','CameraUpVector'});
    if saveFlag
        saveas(gcf,fullfile(path4saveLF,['DifPower_Suprathreshold areas with Thres_' S_thres '_' num2str(thres_method) '.fig']));
    end
    %% plot 2 : ROI & Cortex
%     figure('WindowState','maximized');
    h2 = figure;
    method_Cortex_mark = 1:N;
    plot(method_Cortex_mark,Area_ROI/max(Area_ROI),'-s','Color',[238,118,0]./255,'LineWidth',2,'MarkerFaceColor','auto');
    hold on;
    plot(method_Cortex_mark,Area_Cortex/max(Area_Cortex),'-s','Color',[153,50,204]./255,'LineWidth',2,'MarkerFaceColor','auto');
    hold off;
    xlim([0.5 N+0.5]);
    ylim([0 1.1]);
    ylabel('Suprathreshold brain area proportion','FontSize',12,'LineWidth',2);
    xlabel("Irrelevant region's Power",'FontSize',12,'LineWidth',2);
    title(['Power effect above threshold ' num2str(thres*100) '%']);
    hl = legend('ROI','Cortex');
    set(hl,'FontSize',12);
    set(gca,'xtick',method_Cortex_mark);
    Xticklabel = cell(N,1);
    for i = 1:N
        if method_Cortex(i)==0
            Xticklabel{i} = [num2str(method_Cortex(i)) '(max)'];
        else
%             Xticklabel{i} = [num2str(method_Cortex(i)) ' PWA'];
            Xticklabel{i} = num2str(method_Cortex(i));
        end
    end
    set(gca,'xticklabel',Xticklabel);
    if saveFlag
        saveas(gcf,fullfile(path4saveLF,['DifPower_Suprathreshold brain area proportion with Thres_' S_thres '_' num2str(thres_method) '.tif']));
    end
%     yyaxis left; %Create chart with two y-axes
%     plot(method_Cortex,Area_ROI,'-s','LineWidth',2,'MarkerFaceColor','auto');
%     plot(method_Cortex,Area_ROI/max(Area_ROI),'-s','LineWidth',2,'MarkerFaceColor','auto');
%     ylabel('Suprathreshold area ratio of ROI','FontSize',12,'LineWidth',2);
%     ylim([0 1]);
%     yyaxis right;
%     plot(method_Cortex,Area_Cortex/max(Area_Cortex),'-s','LineWidth',2,'MarkerFaceColor','auto');
%     ylabel('Suprathreshold area ratio of Cortex','FontSize',12,'LineWidth',2);
%     ylim([0 1])
    %     xlabel('Num of elec','FontSize',12,'LineWidth',2);
%     set(gca,'xtick',int8(method_Cortex));
    %% plot 3 : dispersion in Cortex
%     figure('WindowState','maximized');
%     h3 = figure;
%     plot(method_Cortex,Dispersion,'-s','LineWidth',2,'MarkerFaceColor','auto');
%     ylabel('Dispersion of suprathreshold nodes','FontSize',12,'LineWidth',2);
%     %     xlabel('Num of elec','FontSize',12,'LineWidth',2);
%     set(gca,'xtick',int8(method_Cortex));
%     set(gca,'xticklabel',Xticklabel);
%     sgtitle(['Threshold = ' S_thres]);

end
if closeFlag
    close all
end


