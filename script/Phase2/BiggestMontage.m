function [M,c,alpham] = BiggestMontage(Bmax,Bmax2,Bc,Bind)
% M: the max value
% c: the electrode idx 
% alpham : the current arrangement number, current1 = 0.5+0.05*(alpham-1)
N = size(Bmax2,1);
m = zeros(N,1);
im = zeros(N,1);
for i = 1:N
   [m(i),im(i)] =  max(Bmax{i}(:)./Bmax2{i}(:));
end
[M,ic] = max(m);
c = Bc(ic,:);
alpham = Bind{ic}(im(ic));
end

