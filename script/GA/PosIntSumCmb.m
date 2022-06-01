function A = PosIntSumCmb(K,n)
%INTERGERSUMPROBLEM Summary of this function goes here
%   Detailed explanation goes here
   c = nchoosek(2:K,n-1);
   m = size(c,1);
   A = zeros(m,n);
   for ix = 1:m
     A(ix,:) = diff([1,c(ix,:),K+1]);
   end
end

