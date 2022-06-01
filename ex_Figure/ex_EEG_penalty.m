datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROI.name = 'lh.caudalanteriorcingulate';
ROI.multiple = 1;% 将ROI区域向外扩展的
method_ROI = 0;
method_Cortex = 2;
elecNum = 6;
maxColor = 0.2;
Penalty_coef = [1 2 2.5 3];
U = cell(length(Penalty_coef),1);
for i = 1:length(Penalty_coef)
    path4saveLF = fullfile(datapath,'Result',ROI.name,['P_' num2str(Penalty_coef(1,i))]);
     LFfile = fullfile(path4saveLF,'LF.mat');
    load(LFfile);
    path4save = fullfile(path4saveLF,['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
    S = load(fullfile(path4save,['elec' num2str(elecNum) '.mat']),['U' num2str(elecNum) 'm']);
    U{i} = eval(['S.U' num2str(elecNum) 'm']);
    T = tryOnetime(U{i},LF.E_ROI,LF.E_Cortex,LF.NA_ROI,LF.NA_Cortex,method_ROI,method_Cortex);
%     T = tryOnetime(U{i},LF.E_ROI,LF.E_Cortex,LF.NA_ROI,LF.NA_Cortex,0,0);
    disp(T);
end
%% manual plot
i = 4;
[StimProtocol,gray_matter] = Elec_Parameter(U{i},LF);
StimProtocol.method_ROI = method_ROI;
StimProtocol.method_Cortex = method_Cortex;
%绘制电极位置和电流分配图
plotElec1(StimProtocol,LF.electrodes,0);
colorbar off;