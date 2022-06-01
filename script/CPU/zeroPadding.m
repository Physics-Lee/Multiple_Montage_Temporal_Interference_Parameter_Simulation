function [E1,N] = zeroPadding(E0,p)
%ZEROPADDING 此处显示有关此函数的摘要
N = size(E0,1);
Np = p-mod(N,p);
s = size(E0);
if Np<p
Ep = single(zeros([Np,s(2:end)]));
E1 = [E0;Ep];
else
    E1 = E0;
end
end

