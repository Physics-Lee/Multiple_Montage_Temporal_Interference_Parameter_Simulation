function Elf = calculate_Elf_average_of_previous_montages(montage_chosen,ROI_idx,input,elec4)
Elf_temp = zeros(length(ROI_idx),length(montage_chosen)); % 预先分配空间以提高速度
for i = 1:length(montage_chosen)
    Elf_temp(:,i) = input_Elf(input,elec4,montage_chosen(i)); % Elf_temp的每一列是之前某个montage的ELf
end
Elf = mean(Elf_temp,2); % 对Elf_temp按行求平均
end