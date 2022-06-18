function draw_sphere_in_MNI_space(center_of_tet_above_E_threshold_MNI_coord,cfg,color,markertype)
%% draw sphere in MNI space

% draw tet above threshold
global count_of_figure;
figure(count_of_figure)
count_of_figure = count_of_figure + 1;
xlabel('x axis');
ylabel('y axis');
zlabel('z axis');
scatter3(center_of_tet_above_E_threshold_MNI_coord(:,1),center_of_tet_above_E_threshold_MNI_coord(:,2),center_of_tet_above_E_threshold_MNI_coord(:,3),10,color,markertype);
hold on;

% draw ROI
[x,y,z] = sphere();
radius_of_ROI = cfg.ROI.table.Radius;
center_of_ROI = cfg.ROI.table.CoordMNI;
surf(radius_of_ROI*x+center_of_ROI(1),radius_of_ROI*y+center_of_ROI(2),radius_of_ROI*z+center_of_ROI(3));
axis equal;

end