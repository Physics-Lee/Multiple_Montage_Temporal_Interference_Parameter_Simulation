function ptH = Pt2LineFoot(pt,nt,d,center_mid)
%PT2LINEFOOT Summary of this function goes here
%   Detailed explanation goes here
k = (dot(pt(:),nt(:))+d);
ptH = k*nt+center_mid;
end

