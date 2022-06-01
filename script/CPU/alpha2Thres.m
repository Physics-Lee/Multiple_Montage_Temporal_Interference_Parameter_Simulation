function [thres] = alpha2Thres(alpha,thres0)
%METHOD2THRES Summary of this function goes here
%   Detailed explanation goes here
switch alpha
    case -1
        thres = thres0;
    case 0 % volume
        thres = thres0;
    case Inf % max
        thres = thres0;
    otherwise
        thres = thres0^alpha;
end
end

