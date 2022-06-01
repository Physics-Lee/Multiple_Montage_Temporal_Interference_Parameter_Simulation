% this function is used to create cfg.mat

function cfg = TIPSconfig(dataRoot,subMark,simMark)
%% path
% cfg.dataRoot = 'C:\Users\psylab706\Documents\simnibs_examples';
% cfg.subMark = '001';
cfg.dataRoot = dataRoot;
cfg.subMark = subMark;
cfg.simMark = simMark;
cfg.elecNum = 4;
% optimalMethodPool = {'Exhaustion','Genetic Algorithm'};
% cfg.optimalMethod = optimalMethodPool{1};
%% element type
cfg.type = 'tet';
cfg.thres = 0.2; % unit V/m
%% orientation options
cfg.nt = 0;
%% table
varTypes = ["string","double","string","double"];
varNames = ["Name","CoordMNI","Shape","Radius"];
%% ROI
cfg.ROI.num = 1;
cfg.ROI.table = table('Size',[cfg.ROI.num,4],'VariableTypes',varTypes,'VariableNames',varNames);
cfg.ROI.table.Name = 'dACC';
cfg.ROI.table.Shape = 'Sphere';
cfg.ROI.table.CoordMNI = [1 18 39];
cfg.ROI.table.Radius = 5;
cfg.ROI.alpha = Inf;
%% Avoid
cfg.Avoid.num = 0;
cfg.Avoid.table = table('Size',[cfg.Avoid.num,4],'VariableTypes',varTypes,'VariableNames',varNames);
% cfg.Avoid.table.Name = ['l.dlPFC';'r.dlPFC'];
% cfg.Avoid.table.CoordMNI = [-44 6 33;43 9 30];
% cfg.Avoid.table.Radius = [30,30]';
cfg.Avoid.coef = 2;
%% other coefficients
cfg.Other.alpha = Inf;
%% save
% simDir = fullfile(cfg.dataRoot,cfg.subMark,'TI_sim_result',cfg.simMark);
% if ~exist(simDir,'dir')
%     mkdir(simDir);
% end
% save(fullfile(simDir,'cfg.mat'),'cfg');