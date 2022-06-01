function [s1,s2] = subplotnum(plotnum)
%SUBPLOTNUM Summary of this function goes here
%   Detailed explanation goes here
k = sqrt(plotnum);
d1 = floor(10*rem(k,1));% first decimal
if d1<5
    s1=floor(k);
    s2=s1+1;
else
    s1=floor(k)+1;
    s2=s1;
end
end

