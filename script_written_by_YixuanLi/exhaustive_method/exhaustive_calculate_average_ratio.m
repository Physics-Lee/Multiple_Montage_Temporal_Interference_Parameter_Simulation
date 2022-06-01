%% upload cfg.mat and elec4.mat
dataRoot = 'D:\simnibs_examples';
subMark = '011';
simMark = '202204161136_NAc_Radius5_2Divide2_WithoutPenalty';
[cfg,elec4] = upload_cfg_and_elec4(dataRoot,subMark,simMark);

%% use prepare_LF to input E
[input.E,input.volume,~,mesh] = temp_prepare_LF(dataRoot,subMark,cfg);%这句是用来input E的
input.N = size(input.E,1);
input.alpha = Inf;

%% 得到ROI_idx和Other_idx
ROI_idx = TargetRegionIdx(dataRoot,subMark,mesh,cfg.ROI,cfg.type);%这句用来算ROI_idx
Other_idx = ~ROI_idx;

%% calculate ratio_2Divide2
n_interest = 10; % 电极排布方式的总个数为59000个
ratio_2Divide2_matrix = zeros(n_interest,n_interest);
for i = 1:n_interest
    scheme_1 = i;
    Elf_1 = input_Elf(input,elec4,scheme_1); % input_Elf
    for j = i+1:n_interest
        scheme_2 = j;
        Elf_2 = input_Elf(input,elec4,scheme_2); % input_Elf
        Elf = (Elf_1+Elf_2)/2;
        Elf_ROI  = Elf(ROI_idx);
        Elf_Other  = Elf(~ROI_idx);
        ROI_volume = input.volume(ROI_idx);
        Other_volume = input.volume(Other_idx);
        ratio_2Divide2_matrix(i,j) = ((dot(Elf_ROI.^2,ROI_volume)/sum(ROI_volume))/(dot(Elf_Other.^2,Other_volume)/sum(Other_volume)))^(1/2);
    end
end