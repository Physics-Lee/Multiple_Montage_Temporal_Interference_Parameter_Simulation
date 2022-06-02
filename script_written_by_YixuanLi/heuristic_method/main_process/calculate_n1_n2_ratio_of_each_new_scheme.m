function montage_alternative = calculate_n1_n2_ratio_of_each_new_scheme(montage_alternative,i,input,elec4,scheme,Elf,E_threshold,ROI_idx)

scheme_new = montage_alternative(i,7);
Elf_new = input_Elf(input,elec4,scheme_new);
n = length(scheme);
global switch_adding_proportion;

switch switch_adding_proportion
    case 1
        Elf_temp = Elf*n/(n+1)+Elf_new*1/(n+1);
        [montage_alternative(i,8),montage_alternative(i,9)] = find_the_ranking_near_threshold(Elf_temp,E_threshold,ROI_idx);
        montage_alternative(i,10) = heuristic_calculate_average_ratio(input,Elf_temp,ROI_idx);
        montage_alternative(i,11) = 0; 
    case 2
        k_range = 1:9;
        temp = zeros(length(k_range),3);
        count = 1;
        for k = k_range
            Elf_temp = Elf*k/10 + Elf_new*(10-k)/10; % core
            [temp(count,1),temp(count,2)] = find_the_ranking_near_threshold(Elf_temp,E_threshold,ROI_idx);
            temp(count,3) = heuristic_calculate_average_ratio(input,Elf_temp,ROI_idx);
            temp(count,4) = k;
            count = count + 1;
        end
        
        [~,index] = min(temp(:,2));
        montage_alternative(i,8) = temp(index,1);
        montage_alternative(i,9) = temp(index,2);
        montage_alternative(i,10) = temp(index,3);
        montage_alternative(i,11) = temp(index,4);
        
end
end
