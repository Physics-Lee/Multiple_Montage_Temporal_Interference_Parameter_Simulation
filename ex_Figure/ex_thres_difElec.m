datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROI.name = 'lh.insula';
ROI.multiple = 1;% 将ROI区域向外扩展的
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
method_ROI = [0];
method_Cortex = [0];
%% load LF
LFfile = fullfile(path4saveLF,'LF.mat');
if exist(LFfile,'file')==2
    S = load(LFfile);
    LF = S.LF;
    clear S;
else
    error('no LF file');
end
%% plot
saveFlag = true; 
closeFlag = false;
thres_method = 1;
thres = 0.5;
hlink = compareElec_thres(datapath,ROI,method_ROI,method_Cortex,LF,thres_method,thres,saveFlag,closeFlag);
% thres_method: 1--使用ROI最大值乘以 0-1 之间的 thres 系数作为阈值
%               2--使用给定的 thres 数值作为阈值



