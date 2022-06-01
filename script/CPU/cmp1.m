function cmp1(A1,A2)
if ~(isnumeric(A1)&&isnumeric(A2))
    disp('not numeric');
    return;
end
if ~isequal(size(A1),size(A2))
    disp('Different Size');
    return;
end
s = abs(A1-A2);
m = max(s(:));
disp(['max diff is: ' num2str(m)]);
end

