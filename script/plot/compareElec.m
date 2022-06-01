function [hlink] = compareElec(datapath,ROI,method_ROI,method_Cortex,LF,grayMark)
maxColor = 0.2;
path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
path4save = fullfile(path4saveLF,['R' num2str(method_ROI) '_C' num2str(method_Cortex)]);
elecNum = [4,6,8];

load(fullfile(path4save,'elec4.mat'),'U4m');
load(fullfile(path4save,'elec6.mat'),'U6m');
load(fullfile(path4save,'elec8.mat'),'U8m');
%%
figure('WindowState','maximized');
a1 = 1;
a2 = 3;
ax = cell(3,1);
% colorbar on;
for i = 1:3
    S = load(fullfile(path4save,['elec' num2str(elecNum(i)) '.mat']),['U' num2str(elecNum(i)) 'm']);
    U = eval(['S.U' num2str(elecNum(i)) 'm']);
    T = tryOnetime(U,LF.E_ROI,LF.E_Cortex,LF.NA_ROI,LF.NA_Cortex,0,0);
    disp(['elecNum = ' num2str(elecNum(i))]);
    disp(T);
    showU(U);
    ax{i} = subplot(a1,a2,i);
    if(i/a2>1)
        ax{i}.Position(2) = ax{i}.Position(2)+0.1*(floor((i-1)/a2));
    end
    [StimProtocol,gray_matter] = Elec_Parameter(U,LF);
    StimProtocol.method_ROI = method_ROI;
    StimProtocol.method_Cortex = method_Cortex;
%     plotCortex1(gray_matter,maxColor,T.Cortex)
    plotCortex1(gray_matter,maxColor,0);
    title([num2str(elecNum(i)) ' electrodes']);
    axis equal;
end
%%
axC = axes('Position',[0.1367 0.2236 0.7617 0.0273]);
h = colorbar(axC,'FontSize',11);
if grayMark == 1
    colormap('gray');
else
    colormap('Jet');
end
caxis([0 maxColor]);
h.Location = 'south';
h.Position(4) = 0.03;
axis off;
set(get(h,'Title'),'string','V/m');
%%
hlink = linkprop([ax{:}],{'CameraPosition','CameraUpVector'});


