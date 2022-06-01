function number_of_tet_above_E_threshold = calculate_number_of_tet_above_E_threshold(Elf,E_threshold)
    Elf_descend = sortrows(Elf,'descend');
    number_of_tet_above_E_threshold = dsearchn(Elf_descend,E_threshold);
end