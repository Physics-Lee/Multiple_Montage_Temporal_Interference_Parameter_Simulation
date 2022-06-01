%% predefined parameter
datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROI.name = 'lh.caudalanteriorcingulate';
ROI.multiple = 1;% 将ROI区域向外扩展的
method_ROI = 0;
elecNum = 6;
maxColor = 0.2;
%%
% % method_Cortex = 0;
% % Penalty_coef = [1  1.2 1.5  1.8 2 2.2];
%%
method_Cortex = 2;
Penalty_coef = [1 2 2.5 3];
%%
thres_method = 1;
thres = 0.5;
saveFlag = false; 
closeFlag = false;
hlink = comparePenalty_thres(datapath,ROI,method_ROI,method_Cortex,elecNum,Penalty_coef,thres_method,thres,saveFlag,closeFlag);
% comparePenalty_thres(datapath,ROI,method_ROI,method_Cortex,elecNum,Penalty_coef,2,0.12:0.01:0.17);
% thres_method: 1--使用ROI最大值乘以 0-1 之间的 thres 系数作为阈值
%               2--使用给定的 thres 数值作为阈值



