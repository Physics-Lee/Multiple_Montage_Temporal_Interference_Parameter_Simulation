%% predefined parameter
datapath = 'C:\Users\psylab706\Documents\simnibs_examples\ernie'; %被试数据根目录
% datapath = 'E:\MyLabFiles\TI_Simulation\ernie'; %被试数据根目录
ROI.name = 'lh.caudalanteriorcingulate';
ROI.multiple = 1;% 将ROI区域向外扩展的
method_ROI = 0;
elecNum = 6;
maxColor = 0.2;
%%
% method_Cortex = 0;
% Penalty_coef = [1  1.2 1.5  1.8 2 2.2];
%%
method_Cortex = 2;
Penalty_coef = [1 2 2.5 3];
%% figure option
ZscoreMark = false;
grayMark = false;
%% plot
figure('WindowState','maximized');
% [a1,a2] = subplotnum(length(Penalty_coef));
a1 = 2;
a2 = 2;
ax = cell(length(Penalty_coef),1);
for i = 1:length(Penalty_coef)
    ax{i} = subplot(a1,a2,i);
    if(i/a2>1)
        ax{i}.Position(2) = ax{i}.Position(2)+0.1*(floor((i-1)/a2));
    end
    path4saveLF = fullfile(datapath,'Result',ROI.name,['P_' num2str(Penalty_coef(1,i))]);
    path4save = fullfile(path4saveLF,['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
    if ~(exist(path4saveLF,'dir') && exist(path4save,'dir'))
        error('Not correct path!')
    end
    LFfile = fullfile(path4saveLF,'LF.mat');
    load(LFfile);
    S = load(fullfile(path4save,['elec' num2str(elecNum) '.mat']),['U' num2str(elecNum) 'm']);
    U = eval(['S.U' num2str(elecNum) 'm']);
    %%
    T = tryOnetime(U,LF.E_ROI,LF.E_Cortex,LF.NA_ROI,LF.NA_Cortex,method_ROI,method_Cortex);
    disp(['p = ' num2str(Penalty_coef(i))]);
    disp(T);
    showU(U);
    %%
    [StimProtocol,gray_matter] = Elec_Parameter(U,LF);
    StimProtocol.method_ROI = method_ROI;
    StimProtocol.method_Cortex = method_Cortex;
    if (ZscoreMark)
        maxZ = T.ROI;
    else
        maxZ = 0;
    end
    plotCortex1(gray_matter,maxColor,maxZ);
    %     title(num2str(Penalty_coef(i)));
    axis equal;
end
axC = axes('Position',[0.1367 0.1236 0.7617 0.0273]);
h = colorbar(axC,'FontSize',11);
if grayMark
    colormap('gray');
else
    colormap('Jet');
end
caxis([0 maxColor]);
h.Location = 'south';
h.Position(4) = 0.03;
axis off;
if (ZscoreMark)
    set(get(h,'Title'),'string','Zscore');
else
    set(get(h,'Title'),'string','V/m');
end
hlink = linkprop([ax{:}],{'CameraPosition','CameraUpVector'});

