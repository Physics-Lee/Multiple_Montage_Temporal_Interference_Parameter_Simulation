function [n_1,n_2] = find_the_ranking_near_threshold(Elf,E_threshold,ROI_idx)
    % use sortrows to get descendant ranking
    Elf_ROI = Elf(ROI_idx);
    Elf_ROI_descend = sortrows(Elf_ROI,'descend');
    Elf_Other = Elf(~ROI_idx);
    Elf_Other_descend = sortrows(Elf_Other,'descend');
    % use dsearchn to find the number near threshold
    n_1 = dsearchn(Elf_ROI_descend,E_threshold);
    n_2 = dsearchn(Elf_Other_descend,E_threshold);
end