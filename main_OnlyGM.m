% this script is similar to main in C, but only calculate GMS

dataRoot = 'C:\Users\psylab706\Documents\simnibs_examples';
subMark = '001';
simMark = 'dACC_MAX_OnlyGM';
cfg = TIPSconfig(dataRoot,subMark,simMark);
disp(cfg.ROI.table);
%% 
cfg.nt = true;
cfg.Other.alpha = Inf;
cfg.elecNum = 4;
cfg.optimalMethod = 'Exhaustion';
%%
T = OpenTIPS_OnlyGM(cfg);
%%
Um = T2U(T(1,:));
h1 = plotElec1010(Um,electrodes,0);
%%
%% calculation Elf on GMS
[Data,gmS] = LFSurf(dataRoot,subMark);
N = size(Data.E,1);
L = size(Data.E,3);
input.E = single(zeros(N,L));
for i = 1:L
    input.E(:,i) = dot(Data.E(:,:,i),Data.nt,2);
end
input.N = N;
input.alpha = Inf;
input.volume = Data.areas;
[~,~,Elf] = Onetime(input,Um,cfg.thres);
%% get GMS in TR format
TR_GMS = triangulation(gmS.triangles,gmS.nodes);
%% plot
h = plotGMS(TR_GMS,Elf,1,0.2);
