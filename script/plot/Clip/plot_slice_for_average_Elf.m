function h = plot_slice_for_average_Elf(cfg,Elf_average,E_max_in_the_color_bar,clipStr,mode,ROI_center_sub,Avoid_center_sub,direction_xyz)
dataRoot = cfg.dataRoot;
subMark = cfg.subMark;
%% Elf in whole brain
S = load(fullfile(dataRoot,subMark,'TI_sim_result',['Data_' cfg.type '.mat']));
Data = S.Data;
mesh = S.mesh;
clear S;
if cfg.nt
    GMntFile = fullfile(dataRoot,subMark,'orientation','nt_elem_GM.mat');
    GM = load(GMntFile);
    GMnum = size(GM.nt_elem_GM,1);
    nt = single(zeros(size(Data.E,1),3));
    nt(end-GMnum+1:end,:) = GM.nt_elem_GM;
%     nt = single([nt_elem_WM;GM.nt_elem_GM]);
    input.E = single(zeros(size(Data.E,1),size(Data.E,3)));
    for i = 1:size(Data.E,3)
        input.E(:,i) = dot(Data.E(:,:,i),nt,2);
    end
else
    input.E = Data.E;
end
input.alpha = -1;
try
    input.volume = Data.areas;
catch
    input.volume = Data.volume;
end
input.N = size(input.E,1);
%% CSF contour
[node,~,simNIBS_face] = MeshfromSimnibs(dataRoot,subMark);
csfMark = 1003;
face_CSF = double(simNIBS_face(simNIBS_face(:,4)==csfMark,1:3));
TR_CSF = simpleTR(triangulation(face_CSF,node)); % 3d Surface
%% ROI and Avoid region
switch mode
    case 1
        if cfg.ROI.num>0
            ROI_idx = TargetRegionIdx(dataRoot,subMark,mesh,cfg.ROI,cfg.type);
            DT_ROI = simpleTR(triangulation(mesh.DT.ConnectivityList(ROI_idx,:),mesh.DT.Points));
            face_ROI = getSurf(DT_ROI.ConnectivityList);
            TR_ROI = simpleTR(triangulation(face_ROI,DT_ROI.Points));
        else
            disp('No ROI in this clipped section.');
        end
        if cfg.Avoid.num>0
            Avoid_idx = TargetRegionIdx(dataRoot,subMark,mesh,cfg.Avoid,cfg.type);
            DT_Avoid = simpleTR(triangulation(mesh.DT.ConnectivityList(Avoid_idx,:),mesh.DT.Points));
            face_Avoid = getSurf(DT_Avoid.ConnectivityList);
            TR_Avoid = simpleTR(triangulation(face_Avoid,DT_Avoid.Points));
        else
            disp('No Avoid region in this clipped section.');
        end
end
%% In every clip section
for i = direction_xyz
    [TR_section,eIdx] = TetCrossSection(mesh.DT,clipStr{i});
    Elf_section = Elf_average(eIdx,:);
    EV_CSF = SurfCrossSection(TR_CSF,clipStr{i},node);
    [XYZmark,XYZvalue,dof] = str2XYZ(clipStr{i});
    %% plot
    h = maxfigwin();
    title(clipStr{i},'FontSize',20);
    axis equal;
    axis off;
    h = plotCrossSection(h,TR_section,Elf_section,E_max_in_the_color_bar);
    hold on;
    h = plotContour(h,EV_CSF.Points,EV_CSF.Edge{1},dof,'k-','LineWidth',5);
    switch mode
        case 1
            if cfg.ROI.num>0
                EV_ROI = SurfCrossSection(TR_ROI,clipStr{i},node);
                for j = 1:length(EV_ROI.Edge)
                    h = plotContour(h,EV_ROI.Points,EV_ROI.Edge{j},dof,'k-','LineWidth',2);
                end
                
            end
            if cfg.Avoid.num>0
                EV_Avoid = SurfCrossSection(TR_Avoid,clipStr{i},node);
                for j = 1:length(EV_Avoid.Edge)
                    h = plotContour(h,EV_Avoid.Points,EV_Avoid.Edge{j},dof,'b-','LineWidth',2);
                end
                
            end
        case 2
            ax = get(h,'CurrentAxes');
            if cfg.ROI.num>0
                for j = 1:cfg.ROI.num
                    r0 = abs(ROI_center_sub(j,XYZmark)-XYZvalue);
                    if r0 < cfg.ROI.table.Radius(j)
                        r_section = sqrt(cfg.ROI.table.Radius(j)^2-r0^2);
                        center_section = ROI_center_sub(j,dof);
                        viscircles(ax,center_section,r_section,'Color','k','LineWidth',2,'LineStyle','-.');
                    end
                end
            end
            if cfg.Avoid.num>0
                for j = 1:cfg.Avoid.num
                    r0 = abs(Avoid_center_sub(j,XYZmark)-XYZvalue);
                    if r0 < cfg.Avoid.table.Radius(j)
                        r_section = sqrt(cfg.Avoid.table.Radius(j)^2-r0^2);
                        center_section = Avoid_center_sub(j,dof);
                        viscircles(ax,center_section,r_section,'Color','k','LineWidth',2,'LineStyle','-.');
                    end
                end
            end
    end
end
end