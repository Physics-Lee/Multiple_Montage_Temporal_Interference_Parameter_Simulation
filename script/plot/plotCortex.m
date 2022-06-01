function plotCortex(gray_matter,savepath,maxColor)
% maxColor设置colorbar的最大值，如果为空就设为全脑场强的最大值；

%% 绘制全脑电场分布图
viewang = [-90 0;0 90;180 0;90 0;-180 -90;0 0];
axp = [0.05 0.36 0.2 0.8;0.36 0.35 0.2 0.8;0.65 0.36 0.2 0.8;0.05 -0.12 0.2 0.8;0.35 -0.12 0.2 0.8;0.65 -0.12 0.2 0.8];

h1 = figure;
for i = 1:6
    axes('position',axp(i,:));
    hp = patch('Faces',gray_matter.triangles,...
        'Vertices',gray_matter.nodes,'FaceVertexCData',gray_matter.node_data{1,1}.data,...
        'FaceColor','interp','EdgeColor','none',...
        'CDataMapping','scaled','FaceAlpha',1);
    view(gca,[180 0])
    set(gca,'color','none');
    colormap('Jet');
    if isempty(maxColor)
        caxis([0 max(gray_matter.node_data{1,1}.data)])
    else
        caxis([0 maxColor])
    end
    axis equal;
    axis vis3d
    axis off
    view(gca,viewang(i,:));
    material(hp,'dull');
    lighting gouraud
    hlight=camlight('headlight');
    set(gca,'UserData',hlight);
    hrot = rotate3d;
    set(hrot,'ActionPostCallback',@(~,~)camlight(get(gca,'UserData'),'headlight'));
end
axes('position',[.75,.1,.2,.8])
set(gca,'color','none');
axis off
h = colorbar(gca,'FontSize',11);
colormap('Jet');
if isempty(maxColor)
    caxis([0 max(gray_matter.node_data{1,1}.data)])
else
    caxis([0 maxColor])
end
set(get(h,'Title'),'string','V/m');

saveas(gcf,fullfile(savepath,'TI_Cortex.tif'));

%% 绘制可以旋转的fig图像
h2 = figure;
patch('Faces',gray_matter.triangles,...
    'Vertices',gray_matter.nodes,'FaceVertexCData',gray_matter.node_data{1,1}.data,...
    'FaceColor','interp','EdgeColor','none',...
    'CDataMapping','scaled','FaceAlpha',1);
set(gca,'color','none');

h = colorbar(gca,'FontSize',11);
colormap('Jet');
if isempty(maxColor)
    caxis([0 max(gray_matter.node_data{1,1}.data)])
else
    caxis([0 maxColor])
end
set(get(h,'Title'),'string','V/m');

axis equal;
axis vis3d
axis off
view(gca,viewang(i,:));
material(hp,'dull');
lighting gouraud
hlight=camlight('headlight');
set(gca,'UserData',hlight);
hrot = rotate3d;
set(hrot,'ActionPostCallback',@(~,~)camlight(get(gca,'UserData'),'headlight'));

saveas(gcf,fullfile(savepath,'TI_Cortex.fig'));


