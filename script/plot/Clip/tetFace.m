function [face2,ic] = tetFace(DT)
%TETFACE Summary of this function goes here
%   Detailed explanation goes here
elem = DT.ConnectivityList;
face0 = [elem(:,[1 2 3]);elem(:,[1 2 4]);elem(:,[1 3 4]);elem(:,[2 3 4])];
face1 = sort(face0,2);
[face2,~,ic] = unique(face1,'rows');
end

