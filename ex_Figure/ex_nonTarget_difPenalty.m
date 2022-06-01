datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROI.name = 'lh.caudalanteriorcingulate';
ROI.multiple = 1;% 将ROI区域向外扩展的
thres0 = 0.2;
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
method_ROI = 0;
method_Cortex = 2;
% Penalty_coef = [1 1.2 1.5 1.8 2 2.2];
Penalty_coef = [1 2 2.5 3];
%% load
for j = 1:length(Penalty_coef)
    path4saveLF = fullfile(datapath,'Result',ROI.name,['P_' num2str(Penalty_coef(1,j))]);
    path4save = fullfile(path4saveLF,['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
    if ~(exist(path4saveLF,'dir') && exist(path4save,'dir'))
        error('Not correct path!')
    end
    LFfile = fullfile(path4saveLF,'LF.mat');
    load(LFfile);
    
    load(fullfile(path4save,'elec6.mat'),'U6m');
    [StimProtocol{j},gray_matter] = Elec_Parameter(U6m,LF);
    Cortex(:,j) = StimProtocol{j}.TI_Cortex;
    penalty(:,j) = StimProtocol{j}.TI_penalty;
end
%% Cortex区域内场强的分布情况（Normal）
xLabel = {'p = 1','p = 1.2','p = 1.5','p = 1.8','p = 2.0','p = 2.2'};%绘图用，横轴标签/legend

%% penalty区域内场强的分布情况（Beta）
figure;
hold on
x = 0:0.001:thres0;
for im = 1:size(StimProtocol,2)
    pd = fitdist(double(penalty(:,im)),'Beta');
    y = pdf(pd,x);
    plot(x,y,'LineWidth',2)
end
legend(xLabel);
ylabel('probability density','FontSize',15)
xlabel('E_{TI}','FontSize',15)
set(gca,'FontSize',15);
title('distribution of E within penalty region','FontSize',15)

%% irrelevant区域内场强的分布情况（Beta）
figure;
hold on
x = 0:0.001:thres0;
for im = 1:size(StimProtocol,2)
    pd = fitdist(double(Cortex(:,im)),'Beta');
    y = pdf(pd,x);
    plot(x,y,'LineWidth',2)
end
legend(xLabel);
ylabel('probability density','FontSize',15)
xlabel('E_{TI}','FontSize',15)
set(gca,'FontSize',15);
title('distribution of E within irrelevant region','FontSize',15)

