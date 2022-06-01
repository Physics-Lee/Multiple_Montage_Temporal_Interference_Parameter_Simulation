function [m,i,j] = maxMatrix(A)
[m1,i0] = max(A);
[m,j] = max(m1);
i = i0(j);
end

