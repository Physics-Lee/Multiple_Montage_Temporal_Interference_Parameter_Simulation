function [montage_chosen,row_index_of_choosed_montage,flag_break] = criterion_2(montage_chosen,montage_alternative,n_Other_pre,ratio_pre,n_drop)

% 若有n下降2000及以上并且ratio上升的
temp_matrix = NaN;
[row_number,~] = size(montage_alternative); % 行数
count_temp = 1;
flag = 0;

for i = 1:row_number
    if montage_alternative(i,9) <= n_Other_pre - n_drop % 当下降了2000及以上时，才考虑ratio是否上升 %其实之前我的大脑一直都是这么判断的 % 前事不忘，后事之师：下次尽可能快地把人脑的判断标准转化为电脑的判断标准！！！
        temp_matrix(count_temp,1) = i;  % 代表第i行
        temp_matrix(count_temp,2) = montage_alternative(i,7);
        temp_matrix(count_temp,3) = montage_alternative(i,8);
        temp_matrix(count_temp,4) = montage_alternative(i,9); % 代表Other中超过E_threshold的小四面体个数
        temp_matrix(count_temp,5) = montage_alternative(i,10);
        count_temp = count_temp + 1;
    end
end

if count_temp ~= 1 % 如果有montage下降了2000及以上，才进行以下操作
    [ratio_max,row_index_ratio_max] = max(temp_matrix(:,5));
    if ratio_max > ratio_pre % 只需要比pre大就行了，不是必须比最开始的第一大
        row_index_of_choosed_montage = temp_matrix(row_index_ratio_max,1);
        montage_chosen(1,length(montage_chosen)+1) = montage_alternative(row_index_of_choosed_montage,7);
        fprintf('\n------------------------第%d个电极在原始排行榜的名次是%d！！！------------------------\n',length(montage_chosen),montage_chosen(1,length(montage_chosen)));
        fprintf('\n筛选：我是通过【n下降%d及以上并且ratio上升】把它筛选出来的\n',n_drop);
        flag = 1;
        flag_break = 0;
    end
end

% 若无n下降并且ratio上升的，则选n下降得最多的那个
if flag == 0
    [n_Other_now,row_index_of_choosed_montage] = min(montage_alternative(:,9));
    if n_Other_now < n_Other_pre
        montage_chosen(1,length(montage_chosen)+1) = montage_alternative(row_index_of_choosed_montage,7);
        fprintf('\n------------------------第%d个电极在原始排行榜的名次是%d！！！------------------------\n',length(montage_chosen),montage_chosen(1,length(montage_chosen)));
        fprintf('\n筛选：我是通过【n下降得最多】把它筛选出来的\n');
        flag_break = 0;
    else
        fprintf('\nOther中E>E_threshold的小四面体个数没有下降！！！\n');
        flag_break = 1;
    end
end

end