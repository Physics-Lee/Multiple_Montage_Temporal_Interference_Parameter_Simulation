datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
%%
ROI.name = 'lh.insula';
ROI.multiple = 1;
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
LFfile = fullfile(path4saveLF,'LF.mat');
load(LFfile);
path4save = fullfile(path4saveLF,'R0_C0');
S = load(fullfile(path4save,'elec4.mat'),'U4m');
U = S.U4m;
[StimProtoco,gray_matter] = Elec_Parameter(U,LF);
showROI(gray_matter,path4save,1234,5678);
%%
% ROI.name = 'lh.caudalanteriorcingulate';
% path4saveLF = fullfile(datapath,'Result',ROI.name,'P_1');
% LFfile = fullfile(path4saveLF,'LF.mat');
% load(LFfile);
% showROI(LF.gray_matter,path4saveLF,1234,[5678 666]);