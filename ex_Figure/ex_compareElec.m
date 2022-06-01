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
method_ROI = 0;
method_Cortex = 0;
grayMark = 0;
[hlink] = compareElec(datapath,ROI,method_ROI,method_Cortex,LF,grayMark);
