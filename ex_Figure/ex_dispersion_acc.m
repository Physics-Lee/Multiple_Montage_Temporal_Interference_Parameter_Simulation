%% Penalty
ROI.name = 'lh.caudalanteriorcingulate';
ROI.multiple = 1;% 将ROI区域向外扩展的
method_ROI = 0;
p_elecNum = 6;
method_Cortex = 2;
Penalty_coef = [1 2 2.5 3];
thres_method = 1;
thres = 0.5;
N = length(Penalty_coef);
U = cell(N,1);
gray_matter0 = cell(N,1);
StimProtocol0 = cell(N,1);
Area_ROI = zeros(N,length(thres));
Area_Cortex = zeros(N,length(thres));
Area_Penalty = zeros(N,length(thres));
for i = 1:N
    path4saveLF = fullfile(datapath,'Result',ROI.name,['P_' num2str(Penalty_coef(1,i))]);
    path4save = fullfile(path4saveLF,['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
    if ~(exist(path4saveLF,'dir') && exist(path4save,'dir'))
        error('Not correct path!')
    end
    LFfile = fullfile(path4saveLF,'LF.mat');
    load(LFfile);
    S = load(fullfile(path4save,['elec' num2str(p_elecNum) '.mat']),['U' num2str(p_elecNum) 'm']);
    U{i} = eval(['S.U' num2str(p_elecNum) 'm']);
    [StimProtocol0{i},gray_matter0{i}] = Elec_Parameter(U{i},LF);
    if thres_method == 1
        Thres = thres*max(StimProtocol0{i}.TI_ROI);
        S_thres =  num2str(thres);
    elseif thres_method == 2
        Thres = thres;
        S_thres = num2str(thres);
    else
        disp('Wrong thres_method! Please check...');
        return;
    end
    [gray_matter1] = Cortex_thres(gray_matter0{i},Thres,1234,setdiff(unique(gray_matter0{i}.triangle_regions),[1234 666]),666);
    thresIrrelevant_mesh = mesh_extract_regions(gray_matter1, 'region_idx', 9002);
    thresPenalty_mesh = mesh_extract_regions(gray_matter1, 'region_idx', 9003);
    DispersionIrrelevant(i) = DispersionCortex(thresIrrelevant_mesh);
    DispersionPenalty(i) = DispersionCortex(thresPenalty_mesh); 
end
subplot(3,1,3)
N3 = 4;
Penalty_mark = 1:N3;
plot(Penalty_mark,DispersionPenalty,'-s','Color',[0,139,139]./255,'LineWidth',2,'MarkerFaceColor','auto');
hold on
plot(Penalty_mark,DispersionIrrelevant,'-s','Color',[153,50,204]./255,'LineWidth',2,'MarkerFaceColor','auto');
xlabel("Penalty coefficient",'FontSize',12,'LineWidth',2);
set(gca,'xtick',Penalty_mark);
% h1 = legend('Penalty area','Irrelevant area');
% set(h1,'FontSize',8);
Xticklabel3 = cell(N3,1);
for i = 1:N3
    Xticklabel3{i} = num2str(Penalty_coef(i));
end
set(gca,'xticklabel',Xticklabel3);
xlim([0.5 N3+0.5]);
ylim([min(DispersionPenalty)-8,max(DispersionIrrelevant)+8]);