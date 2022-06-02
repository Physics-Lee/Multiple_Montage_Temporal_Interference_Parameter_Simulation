function [montage_chosen,row_index_of_choosed_montage,flag_break] = criterion_1(montage_chosen,montage_alternative,n_Other_pre)

[n_Other_now,row_index_of_choosed_montage] = min(montage_alternative(:,9));
if n_Other_now < n_Other_pre
    montage_chosen(1,length(montage_chosen)+1) = montage_alternative(row_index_of_choosed_montage,7);
    fprintf('\n------------------------第%d个电极在原始排行榜的名次是%d！！！------------------------\n',length(montage_chosen),montage_chosen(1,length(montage_chosen)));
    fprintf('\n筛选标准：我是通过【n下降得最多】把它筛选出来的\n');
    flag_break = 0;
else
    flag_break = 1;
end

end