% datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROI.name = 'lh.insula';
ROI.multiple = 1;% 将ROI区域向外扩展的
thres0 = 0.2;
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
method_ROI = [0,0,0,0];
method_Cortex = [0,1,2,4];
%% load
LFfile = fullfile(path4saveLF,'LF.mat');
if exist(LFfile,'file')==2
    S = load(LFfile);
    LF = S.LF;
    clear S;
else
    error('no LF file');
end
for j = 1:size(method_ROI,2)
path4save = fullfile(path4saveLF,['R' num2str(method_ROI(j)) '_C' num2str(method_Cortex(j))]);
load(fullfile(path4save,'elec8.mat'),'U8m');
[StimProtocol{j},gray_matter] = Elec_Parameter(U8m,LF);
Cortex(:,j) = StimProtocol{j}.TI_Cortex;
end
%% Cortex区域内场强的分布情况（Normal）
xLabel = {'max','1 power weighted average','2 power weighted average','4 power weighted average'};%绘图用，横轴标签/legend
figure;
hold on
x = 0:0.001:thres0;
for im = 1:size(StimProtocol,2)
    pd = fitdist(Cortex(:,im),'Normal');
    y = pdf(pd,x);
    plot(x,y,'LineWidth',2)
end
legend(xLabel);
ylabel('probability density','FontSize',15)
xlabel('E_{TI}','FontSize',15)
set(gca,'FontSize',15);
title('distribution of E within non-target region','FontSize',15)

% saveas(gcf,fullfile(path4saveLF,'Normal distribution of E within ROI.tif'));
%% Cortex区域内场强的分布情况（Beta）
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
title('distribution of E within non-target region','FontSize',15)

% saveas(gcf,fullfile(path4saveLF,'Beta distribution of E within ROI.tif'));
