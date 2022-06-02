function ranking_list_of_200w_tet_descend = get_ranking_list_of_200w_tet(hdf5,Elf,ROI_idx)
% 得到灰质、白质的索引
index_of_grey_and_white = ismember(hdf5(2).mesh.tetrahedron_regions,[1,2]);

% 得到小四面体体积
volume_temp = mesh_get_tetrahedron_sizes(hdf5(2).mesh);
volume_of_grey_and_white = volume_temp(index_of_grey_and_white);

% 得到小四面体顶点的索引
tet_vertice_index = hdf5(2).mesh.tetrahedra(index_of_grey_and_white,:);

% 把以上数据组装为ranking_list_of_200w_tet_descend，第1列为Elf，第2列为体积，3-6列为顶点索引，第7列为小四面体索引
ranking_list_of_200w_tet_out_of_order = zeros(length(ROI_idx),6);
ranking_list_of_200w_tet_out_of_order(:,1) = Elf;
ranking_list_of_200w_tet_out_of_order(:,2) = volume_of_grey_and_white;
ranking_list_of_200w_tet_out_of_order(:,3:6) = tet_vertice_index;
ranking_list_of_200w_tet_out_of_order(:,7) = 1:length(ROI_idx);
ranking_list_of_200w_tet_descend = sortrows(ranking_list_of_200w_tet_out_of_order,1,'descend');
end