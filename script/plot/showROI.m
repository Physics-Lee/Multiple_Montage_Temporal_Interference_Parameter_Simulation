function showROI(gray_matter,savepath,ROI_label,TakeOut_label)
%% 绘制ROI的位置和结构
% gray_matter = leadfield.gray_matter;
ROI_mesh = mesh_extract_regions(gray_matter, 'region_idx', ROI_label);
TakeOut_mesh =  mesh_extract_regions(gray_matter, 'region_idx', TakeOut_label);

TR = triangulation(double(gray_matter.triangles),gray_matter.nodes);
TR_ROI = triangulation(double(ROI_mesh.triangles),ROI_mesh.nodes);

viewang = [-90 0;0 90;180 0;90 0;-180 -90;0 0]; %分图视角
axp = [0.05 0.36 0.2 0.8;0.36 0.35 0.2 0.8;0.65 0.36 0.2 0.8;0.05 -0.12 0.2 0.8;0.35 -0.12 0.2 0.8;0.65 -0.12 0.2 0.8];%分图位置
h = figure;
for i = 1:6
    hp = axes('position',axp(i,:));
    showTR_facealpha(TR,TR_ROI,[139,0,0]);
    view(gca,[180 0])
    set(gca,'color','none');
    
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

saveas(gcf,fullfile(savepath,'theROI.tif'));

%% 绘制ROI形状和位置的图示
figure;
showTR_facealpha(TR,TR_ROI,[139,0,0]);
set(gca,'color','none');

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

saveas(gcf,fullfile(savepath,'theROI.fig'));

%% 把扣除的部分也画出来
if ~isempty(TakeOut_mesh.triangles)
    TR_TO = triangulation(double(TakeOut_mesh.triangles),TakeOut_mesh.nodes);
    viewang = [-90 0;0 90;180 0;90 0;-180 -90;0 0]; %分图视角
    axp = [0.05 0.36 0.2 0.8;0.36 0.35 0.2 0.8;0.65 0.36 0.2 0.8;0.05 -0.12 0.2 0.8;0.35 -0.12 0.2 0.8;0.65 -0.12 0.2 0.8];%分图位置
    h = figure;
    for i = 1:6
        hp = axes('position',axp(i,:));
        showTR_facealpha(TR,TR_ROI,[139,0,0]);
        hold on
        showTR_facealpha(TR,TR_TO,[0,0,139]);
        view(gca,[180 0])
        set(gca,'color','none');
        
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
    
    saveas(gcf,fullfile(savepath,'theROI_and_TOareas.tif'));% TO: take out
    
    %% 绘制ROI形状和位置的图示
    figure;
    showTR_facealpha(TR,TR_ROI,[139,0,0]);
    hold on
    showTR_facealpha(TR,TR_TO,[0,0,139]);
    set(gca,'color','none');
    
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
    
    saveas(gcf,fullfile(savepath,'theROI_and_TOareas.fig'));
end

