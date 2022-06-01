function h = plotElec1010(U,elec,grayMark)
% 绘制电极位置和电流强度
%% Electrode postions
[elecXY,elecName] =  electrode_Pos();
elec = deblank(elec);
elecFigureIdx = cellfun(@(x) find(strcmp(x,elecName)),elec);
a_elecIdx = elecFigureIdx(U.a.elec);
b_elecIdx = elecFigureIdx(U.b.elec);
%% Electrode Color
minCurrent = -2;
maxCurrent = 2;
stepCurrent = 0.05;
current = (minCurrent:stepCurrent:maxCurrent)';
Ncolor = length(current);
if grayMark ==1
    colorMap = flip(cbrewer('seq','Greys', Ncolor),1); %设定colormap的颜色
    colorMap(colorMap>1) = 1;
    colorMap(colorMap<0) = 0;
else
    colorMap = flip(cbrewer('div','Spectral', Ncolor),1); %设定colormap的颜色
    colorMap(colorMap>1) = 1;
    colorMap(colorMap<0) = 0;
end
a_elecColor = interp1(current,colorMap,U.a.cu,'linear');
b_elecColor = interp1(current,colorMap,U.b.cu,'linear');
%% elec Frame
a_curve = [1,1];
b_curve = [0,0];
%% plot
h = maxfigwin();%绘图窗口最大化
hold on;
axis equal;
axis off;
%% The head
lineWidHead = 1;
lineWidTarget = 2;
elec_r = 0.34;
elecCircle([0 0],'',5,'k','none',lineWidHead,11,[1,1]);
elecCircle([0 0],'',4,'k','none',lineWidHead,11,[1,1]);
line([-5 5],[0 0],'Color','k','LineWidth',lineWidHead);
line([0 0],[-5 5],'Color','k','LineWidth',lineWidHead);
line([-0.5 0],[sqrt(25-0.5^2) 5.5],'Color','k','LineWidth',lineWidHead);
line([0.5 0],[sqrt(25-0.5^2) 5.5],'Color','k','LineWidth',lineWidHead);
%% Other electrodes
elecIdxOther= setdiff(elecFigureIdx,[a_elecIdx;b_elecIdx]);
for i = 1:length(elecIdxOther)
    elecCircle(elecXY(elecIdxOther(i),:),elecName(elecIdxOther(i)),elec_r,'k','w',lineWidHead,9,[1,1]);
end
%% a electrodes
for i = 1:U.a.elecNum
    elecCircle(elecXY(a_elecIdx(i),:),elecName(a_elecIdx(i)),elec_r,'k',a_elecColor(i,:),lineWidTarget,9,a_curve);
end
%% b electrodes
for i = 1:U.b.elecNum
    elecCircle(elecXY(b_elecIdx(i),:),elecName(b_elecIdx(i)),elec_r,'k',b_elecColor(i,:),lineWidTarget,9,b_curve);
end
%% colorbar
set(gca,'CLim',[-2 2],'colorMap',...
    colorMap,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[6.5 5 1]);
colorbar;
% %% Label the Elecs using the number
% h = maxfigwin();%绘图窗口最大化
% 
% %% The head
% elecCircle([0 0],'',5,'k','none',lineWidHead,11,[1,1]);
% elecCircle([0 0],'',4,'k','none',lineWidHead,11,[1,1]);
% axis equal;
% line([-5 5],[0 0],'Color','k','LineWidth',lineWidHead);
% line([0 0],[-5 5],'Color','k','LineWidth',lineWidHead);
% line([-0.5 0],[sqrt(25-0.5^2) 5.5],'Color','k','LineWidth',lineWidHead);
% line([0.5 0],[sqrt(25-0.5^2) 5.5],'Color','k','LineWidth',lineWidHead);
% elecCircle(Ele4fre1,Lab4fre1_num,ele_r,Col4fre1,col4fre1,lineWidTarget,12,curvatureFre1);
% elecCircle(Ele4fre2,Lab4fre2_num,ele_r,Col4fre2,col4fre2,lineWidTarget,12,curvatureFre2);
% 
% set(gca,'CLim',[-2 2],'colorMap',...
%     colorMap,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[6.5 5 1]);
% colorbar;
% 
% elecCircle(Ele_array,Label_idx,ele_r,'k','w',lineWidHead,12,[1,1]);
% axis off
% 
% elecCircle(Ele4fre1,Lab4fre1,ele_r,Col4fre1,col4fre1,lineWidTarget,9,curvatureFre1);
% elecCircle(Ele4fre2,Lab4fre2,ele_r,Col4fre2,col4fre2,lineWidTarget,9,curvatureFre2);
% 

% %%　plot 






