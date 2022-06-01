datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROI.name = 'lh.insula';
ROI.multiple = 1;% 将ROI区域向外扩展的
method_ROI = [0,0,0,0];
method_Cortex = [0,1,2,4];
elecNum = 6;
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
U = cell(length(method_Cortex),1);
for i = 1:length(method_Cortex)
    path4save = fullfile(path4saveLF,['R' num2str(method_ROI(i)) '_C' num2str(method_Cortex(i))]);
    LFfile = fullfile(path4saveLF,'LF.mat');
    load(LFfile);
    S = load(fullfile(path4save,['elec' num2str(elecNum) '.mat']),['U' num2str(elecNum) 'm']);
    U{i} = eval(['S.U' num2str(elecNum) 'm']);
    T = tryOnetime(U{i},LF.E_ROI,LF.E_Cortex,LF.NA_ROI,LF.NA_Cortex,0,0);
    disp(T);
end
%% manual plot
i = 4;
[StimProtocol,gray_matter] = Elec_Parameter(U{i},LF);
StimProtocol.method_ROI = method_ROI;
StimProtocol.method_Cortex = method_Cortex(i);
%绘制电极位置和电流分配图
plotElec1(StimProtocol,LF.electrodes,0);
colorbar off;