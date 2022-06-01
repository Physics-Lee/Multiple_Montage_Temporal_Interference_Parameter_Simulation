datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROI.name = 'lh.insula';
ROI.multiple = 1;
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
%% load LF
LFfile = fullfile(path4saveLF,'LF.mat');
if exist(LFfile,'file')==2
    S = load(LFfile);
    LF = S.LF;
    clear S;
else
    error('no LF file');
end
%% thres
thres_method = 1;
thres = 0.5;
%% power
method_CortexP = [0,1,2,4];
method_ROI = zeros(size(method_CortexP));
N = length(method_CortexP);
DispersionPower = zeros(N,1);
elecNumP= 6;
for i = 1:N
    path4save = fullfile(path4saveLF,['R' num2str(method_ROI(i)) '_C' num2str(method_CortexP(i))]);
    S = load(fullfile(path4save,['elec' num2str(elecNumP) '.mat']),['U' num2str(elecNumP) 'm']);
    U = eval(['S.U' num2str(elecNumP) 'm']);
    [StimProtocol,gray_matter0] = Elec_Parameter(U,LF);
    if thres_method == 1
        Thres = thres*max(StimProtocol.TI_ROI);
    else
        Thres = thres;
    end
    [gray_matter1] = Cortex_thres(gray_matter0,Thres,1234,setdiff(unique(gray_matter0.triangle_regions),1234),[]);
    thresCortex_mesh = mesh_extract_regions(gray_matter1, 'region_idx', 9002);
    DispersionPower(i) = DispersionCortex(thresCortex_mesh);
end
%% Elec
elecNum = [4,6,8];
method_ROI = 0;
method_Cortex = 0;
N = length(elecNum);
path4save = fullfile(path4saveLF,['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
DispersionElec = zeros(N,1);
for i = 1:N
    S = load(fullfile(path4save,['elec' num2str(elecNum(i)) '.mat']),['U' num2str(elecNum(i)) 'm']);
    U = eval(['S.U' num2str(elecNum(i)) 'm']);
    [StimProtocol,gray_matter0] = Elec_Parameter(U,LF);
    if thres_method == 1
        Thres = thres*max(StimProtocol.TI_ROI);
    else
        Thres = thres;
    end
    [gray_matter1] = Cortex_thres(gray_matter0,Thres,1234,setdiff(unique(gray_matter0.triangle_regions),1234),[]);
    thresCortex_mesh = mesh_extract_regions(gray_matter1, 'region_idx', 9002);
    DispersionElec(i) = DispersionCortex(thresCortex_mesh);
end
%% plot
h = figure;
subplot(2,1,1)
% yyaxis left;
N1 = 4;
method_Cortex_mark = 1:N1;
% plot(method_Cortex_mark,DispersionPower,'-s','Color',[0.8500 0.3250 0.0980],'LineWidth',2,'MarkerFaceColor','auto');
plot(method_Cortex_mark,DispersionPower,'-ks','LineWidth',2,'MarkerFaceColor','auto');
xlabel("Irrelevant region's Power",'FontSize',12,'LineWidth',2);
set(gca,'xtick',method_Cortex_mark);
Xticklabel1 = cell(N1,1);
for i = 1:N1
    if method_CortexP(i)==0
        Xticklabel1{i} = [num2str(method_CortexP(i)) '(max)'];
    else
        Xticklabel1{i} = num2str(method_CortexP(i));
    end
end
set(gca,'xticklabel',Xticklabel1);
xlim([0.5 4.5]);
ylim([min(DispersionPower)-5,max(DispersionPower)+5]);
% yyaxis right;
subplot(2,1,2)
N2 = 3;
elecNum_mark = 1:N2;
plot(elecNum_mark,DispersionElec,'-ks','LineWidth',2,'MarkerFaceColor','auto');
xlabel("Electrode number",'FontSize',12,'LineWidth',2);
set(gca,'xtick',elecNum_mark);
Xticklabel2 = cell(N2,1);
for i = 1:N2
    Xticklabel2{i} = num2str(elecNum(i));
end
set(gca,'xticklabel',Xticklabel2);
xlim([0.5 N2+0.5]);
ylim([min(DispersionElec)-4,max(DispersionElec)+4]);
% ylabel({'Average distance to center of gravity';'[mm]'},'FontSize',12);

saveas(gcf,fullfile(path4saveLF,['Dispersion with Thres_' num2str(Thres) '_' num2str(thres_method) '.tif']));

%  sgtitle(['Threshold = ' num2str(thres*100) '%']);