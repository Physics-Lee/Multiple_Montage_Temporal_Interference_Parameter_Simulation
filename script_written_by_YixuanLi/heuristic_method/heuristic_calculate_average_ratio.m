function ratio_2Divide2 = heuristic_calculate_average_ratio(input,Elf,ROI_idx)
    Elf_ROI  = Elf(ROI_idx);
    Elf_Other  = Elf(~ROI_idx);
    ROI_volume = input.volume(ROI_idx);
    Other_volume = input.volume(~ROI_idx);
    ratio_2Divide2 = ((dot(Elf_ROI.^2,ROI_volume)/sum(ROI_volume))/(dot(Elf_Other.^2,Other_volume)/sum(Other_volume)))^(1/2);
end