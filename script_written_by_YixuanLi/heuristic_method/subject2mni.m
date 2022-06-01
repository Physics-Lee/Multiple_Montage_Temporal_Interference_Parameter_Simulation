function center_of_tet_above_E_threshold_MNI_coord = subject2mni(hdf5,ranking_list_of_200w_tet_descend,cfg,Elf,E_threshold)

dataRoot = cfg.dataRoot;
subMark = cfg.subMark;
directory_of_subject2mni_coords = [fullfile(dataRoot,subMark) '\m2m_' subMark '/'];

% 得到小四面体顶点的subject坐标
tet_vertice_subject_coord = hdf5(2).mesh.nodes; % 数组下标为顶点索引，三列分别为x坐标、y坐标、z坐标。

% calculate the center of tet
Elf_descend = sortrows(Elf,'descend');
number_of_tet_above_E_threshold = dsearchn(Elf_descend,E_threshold);
center_of_tet_above_E_threshold_subject_coord = zeros(number_of_tet_above_E_threshold,3);
sum_temp = [0 0 0]; % set to 0
for j = 1:number_of_tet_above_E_threshold
    for i = 3:6
        sum_temp = sum_temp + tet_vertice_subject_coord(ranking_list_of_200w_tet_descend(j,i),:);% calculate the sum of 4 vertices
    end
    center_of_tet_above_E_threshold_subject_coord(j,:) = sum_temp/4; % calculate the average of 4 vertices
    sum_temp = [0 0 0]; % set to 0 for next cycle
end

% convert subject coords to MNI coords
temp = subject2mni_coords(center_of_tet_above_E_threshold_subject_coord,directory_of_subject2mni_coords, 'nonl');% let the user change it

% 取整
center_of_tet_above_E_threshold_MNI_coord = round(temp);

end