function [B] = changem1(A,newval,oldval)
% new version of changem, from httnewvals://stackoverflow.com/a/13815291/8838249
% raw changem is too slow   
B = zeros(size(A));
[a,b] = ismember(A,oldval);
B(a) = newval(b(a));
end

