datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROI.name = 'lh.insula';
ROI.multiple = 1;% 将ROI区域向外扩展的
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
LFfile = fullfile(path4saveLF,'LF.mat');
if exist(LFfile,'file')==2
    S = load(LFfile);
    LF = S.LF;
    clear S;
else
    error('no LF file');
end
method_ROI = [0,0,0,0];
method_Cortex = [0,1,2,4];
%%
% grayMark = 0;
% [hlink] = comparePower(datapath,ROI,method_ROI,method_Cortex,LF,grayMark);
elecNum = 6;
thres_method = 1;
thres = 0.5;
saveFlag = true; 
closeFlag = false;
hlink = comparePower_thres(datapath,ROI,method_ROI,method_Cortex,LF,elecNum,thres_method,thres,saveFlag,closeFlag);

% comparePower_thres(datapath,ROI,method_ROI,method_Cortex,LF,2,0.14);
% thres_method: 1--使用ROI最大值乘以 0-1 之间的 thres 系数作为阈值
%               2--使用给定的 thres 数值作为阈值



