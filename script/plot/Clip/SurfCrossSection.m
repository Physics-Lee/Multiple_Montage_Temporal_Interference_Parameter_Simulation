function [EV,p0,p1] = SurfCrossSection(TR,str,node)
%UNTITLED Summary of this function goes here
%% head shell surface mesh
[XYZmark,XYZvalue] = str2XYZ(str);
%% 4 point cross section plane
p0 = floor(min(node)-5);
p1 = ceil(max(node)+5);
switch XYZmark
    case 1 %x
        pt4 = [ones(4,1)*XYZvalue,[p0([2,3]);p1([2,3]);p0(2),p1(3);p1(2),p0(3)]];
    case 2 %y
        pt4 = [[p0(1);p1(1);p0(1);p1(1)],ones(4,1)*XYZvalue,[p0(3);p1(3);p1(3);p0(3)]];
    case 3 %z
        pt4 = [[p0([1,2]);p1([1,2]);p0(1),p1(2);p1(1),p0(2)],ones(4,1)*XYZvalue];
end
TR4 = triangulation([1,2,3;1,4,2],pt4);
%% 
[EV.Edge,EV.Points]= OneContour(TR4,TR);



