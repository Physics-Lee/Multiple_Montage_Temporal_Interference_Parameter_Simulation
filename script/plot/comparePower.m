function [hlink] = comparePower(datapath,ROI,method_ROI,method_Cortex,elecNum,LF,grayMark)
maxColor = 0.2;
U = cell(length(method_Cortex),1);
for i = 1:length(method_Cortex)
    path4saveLF = fullfile(datapath,'Result',ROI.name,['M' num2str(ROI.multiple)]);
    path4save = fullfile(path4saveLF,['R' num2str(method_ROI(i)) '_C' num2str(method_Cortex(i))]);
    % load(fullfile(path4save,'elec4.mat'),'U4m');
%     S = load(fullfile(path4save,'elec6.mat'),'U6m');
    
    S = load(fullfile(path4save,['elec' num2str(elecNum) '.mat']),['U' num2str(elecNum) 'm']);
    U{i} = eval(['S.U' num2str(elecNum) 'm']);
end
%%
figure('WindowState','maximized');
ax = cell(length(method_Cortex),1);
for i = 1:4
    ax{i} = subplot(2,2,i);
    if(i>2)
        ax{i}.Position(2) = ax{i}.Position(2)+0.1;
    end
%     ax{i}.Position(4) = ax{i}.Position(3);
    [StimProtocol,gray_matter] = Elec_Parameter(U{i},LF);
     T = tryOnetime(U{i},LF.E_ROI,LF.E_Cortex,LF.NA_ROI,LF.NA_Cortex,0,0);
    disp(T);
    StimProtocol.method_ROI = method_ROI(i);
    StimProtocol.method_Cortex = method_Cortex(i);
    plotCortex1(gray_matter,maxColor,0);% 
    if method_Cortex(i)==0
        title('max')
    else
        title([num2str(method_Cortex(i)) ' power weighted average']);
    end
    axis equal;
end
%%
axC = axes('Position',[0.1367 0.1236 0.7617 0.0273]);
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
hlink = linkprop([ax{1},ax{2},ax{3},ax{4}],{'CameraPosition','CameraUpVector'});


