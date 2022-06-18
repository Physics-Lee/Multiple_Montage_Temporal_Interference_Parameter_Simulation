function avoid_idx = calculate_avoid_idx(cfg,Elf,E_threshold,ROI_idx,distance_ascend,center_of_tet_above_E_threshold_MNI_coord)

R_threshold = cfg.ROI.table.Radius; % 暂时取为cfg.ROI.table.Radius
number_of_tet_above_E_threshold = size(center_of_tet_above_E_threshold_MNI_coord,1);

if R_threshold == cfg.ROI.table.Radius
    Elf_ROI = Elf(ROI_idx); % 惩罚半径比ROI半径小
    Elf_ROI_descend = sortrows(Elf_ROI,'descend');
    number_of_tet_below_R_threshold = dsearchn(Elf_ROI_descend,E_threshold);
elseif R_threshold > cfg.ROI.table.Radius % 惩罚半径比ROI半径大
    number_of_tet_below_R_threshold = dsearchn(distance_ascend(:,1),R_threshold); % 分成两句写是因为这样算出来的竟然会有一部分在ROI里！！！
end

avoid_idx = zeros(length(ROI_idx),1);
for i = number_of_tet_below_R_threshold + 1:number_of_tet_above_E_threshold % 注意i的取值范围
    avoid_idx(distance_ascend(i,2)) = 1;
end

end