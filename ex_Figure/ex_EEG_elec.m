datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROIa.name = 'lh.insula';
ROIa.multiple = 1;% 将ROI区域向外扩展的
method_ROI = 0;
method_Cortex = 0;
path4saveLF = fullfile(datapath,'Result',ROIa.name,['M' num2str(ROIa.multiple)]);
path4save = fullfile(path4saveLF,['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
%% load
% LFfile = fullfile(path4saveLF,'LF.mat');
% if exist(LFfile,'file')==2
%     S = load(LFfile);
%     LF = S.LF;
%     clear S;
% else
%     error('no LF file');
% end
load(fullfile(path4save,'elec4.mat'),'U4m');
load(fullfile(path4save,'elec6.mat'),'U6m');
load(fullfile(path4save,'elec8.mat'),'U8m');
%%
[StimProtocol,gray_matter] = Elec_Parameter(U8m,LF);
StimProtocol.method_ROI = method_ROI;
StimProtocol.method_Cortex = method_Cortex;
%绘制电极位置和电流分配图
plotElec1(StimProtocol,LF.electrodes,0);