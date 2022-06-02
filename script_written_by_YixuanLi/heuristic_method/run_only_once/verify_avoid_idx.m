function avoid_idx = verify_avoid_idx(cfg,Elf,E_threshold,ROI_idx,color,markertype,count_main_round,flag_break,directory)
% %% verify avoid_idx
% 
% avoid_tet_ranking_number = find(avoid_idx);
% avoid_tet_vertice_index = zeros(length(avoid_tet_ranking_number),4);
% for i = 1:length(avoid_tet_ranking_number)
%     avoid_tet_vertice_index(i,:) = tet_vertice_index(avoid_tet_ranking_number(i),:);
% end
% 
% % 算小四面体中心坐标
% center_of_avoid_tet_subject_coord = zeros(length(avoid_tet_ranking_number),3);
% sum_temp = [0 0 0]; % set to 0
% for j = 1:length(avoid_tet_ranking_number)
%     
%     % calculate the center of tet
%     for i = 1:4
%         sum_temp = sum_temp + tet_vertice_subject_coord(avoid_tet_vertice_index(j,i),:);% calculate the sum of 4 vertices
%     end
%     center_of_avoid_tet_subject_coord(j,:) = sum_temp/4; % calculate the average of 4 vertices
%     
%     % set to 0 for next cycle
%     sum_temp = [0 0 0];
%     
% end
% 
% % convert subject coords to MNI coords
% temp = subject2mni_coords(center_of_avoid_tet_subject_coord,directory_of_subject2mni_coords, 'nonl');% let the user change it
% 
% % 取整
% center_of_avoid_tet_MNI_coord = round(temp);
% 
% % draw tet above threshold
% figure(3)
% xlabel('x axis');
% ylabel('y axis');
% zlabel('z axis');
% scatter3(center_of_avoid_tet_MNI_coord(:,1),center_of_avoid_tet_MNI_coord(:,2),center_of_avoid_tet_MNI_coord(:,3),10);
% hold on;
% 
% % draw ROI
% [x,y,z] = sphere();
% radius_of_ROI = cfg.ROI.table.Radius;
% center_of_ROI = cfg.ROI.table.CoordMNI;
% surf(radius_of_ROI*x+center_of_ROI(1),radius_of_ROI*y+center_of_ROI(2),radius_of_ROI*z+center_of_ROI(3));
% axis equal;

end