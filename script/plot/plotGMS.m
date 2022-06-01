function h = plotGMS(TR_GMS,nodeData,maxColor,maxZ)
if maxZ >0 
% average by Z
    nodeData = nodeData/maxZ;
    maxColor = 1;
end
% Copy from plotCortex 1, Only make the rotation fig
h = patch('Faces',TR_GMS.ConnectivityList,...
    'Vertices',TR_GMS.Points,'FaceVertexCData',nodeData,...
    'FaceColor','interp','EdgeColor','none',...
    'CDataMapping','scaled','FaceAlpha',1);
set(gca,'color','none');

colormap('Jet');
if isempty(maxColor)
    caxis([0 max(nodeData)])
else
    caxis([0 maxColor])
end

%% light
material(h,'dull');
lighting gouraud;
hlight=camlight('headlight');
set(gca,'UserData',hlight);
axis equal;
axis vis3d
axis off
hrot = rotate3d;
set(hrot,'ActionPostCallback',@(~,~)camlight(get(gca,'UserData'),'headlight'));
end

