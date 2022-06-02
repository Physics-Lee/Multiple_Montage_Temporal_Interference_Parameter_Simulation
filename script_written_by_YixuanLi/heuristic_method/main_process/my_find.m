function answer = my_find(x,x_0) % 在列向量x中寻找标量x_0，若能找到则返回其下标，若找不到则返回空数组
    temp = find(~(x-x_0)) ~= 0;
    answer = ~isempty(temp); %不加这句会报错
end