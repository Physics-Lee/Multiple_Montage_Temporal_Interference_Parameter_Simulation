function plotCortex1(gray_matter,maxColor,maxZ)
if maxZ >0 
% average by Z
    gray_matter.node_data{1}.data = gray_matter.node_data{1}.data/maxZ;
    maxColor = 1;
end
% Copy from plotCortex 1, Only make the rotation fig
hp = patch('Faces',gray_matter.triangles,...
    'Vertices',gray_matter.nodes,'FaceVertexCData',gray_matter.node_data{1,1}.data,...
    'FaceColor','interp','EdgeColor','none',...
    'CDataMapping','scaled','FaceAlpha',1);
set(gca,'color','none');

colormap('Jet');
if isempty(maxColor)
    caxis([0 max(gray_matter.node_data{1,1}.data)])
else
    caxis([0 maxColor])
end

% axis equal;
axis vis3d
axis off
% view(gca,viewang(i,:));
%% light
material(hp,'dull');
lighting gouraud;
hlight=camlight('headlight');
set(gca,'UserData',hlight);
% hrot = rotate3d;
% set(hrot,'ActionPostCallback',@(~,~)camlight(get(gca,'UserData'),'headlight'));
end

