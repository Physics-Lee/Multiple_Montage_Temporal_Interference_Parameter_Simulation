function histogram_ROI_Other(Elf,ROI_idx,count_main_round,flag_break,directory)

% get Elf at ROI and Other
Elf_ROI = Elf(ROI_idx);
Elf_Other = Elf(~ROI_idx);

% draw histogram
global count_of_figure;

figure(count_of_figure);
count_of_figure = count_of_figure + 1;
global edges_of_hist_ROI_and_hist_Other;
h_ROI = histogram(Elf_ROI,edges_of_hist_ROI_and_hist_Other);

figure(count_of_figure);
count_of_figure = count_of_figure + 1;
h_Other = histogram(Elf_Other,edges_of_hist_ROI_and_hist_Other);

% save
if count_main_round == 1
    hist_ROI_start = h_ROI.Values;
    hist_Other_start = h_Other.Values;
    save(fullfile(directory,'hist_ROI_start.mat'),'hist_ROI_start');
    save(fullfile(directory,'hist_Other_start.mat'),'hist_Other_start');
end

if flag_break == 1
    hist_ROI_end = h_ROI.Values;
    hist_Other_end = h_Other.Values;
    save(fullfile(directory,'hist_ROI_end.mat'),'hist_ROI_end');
    save(fullfile(directory,'hist_Other_end.mat'),'hist_Other_end');
end

end