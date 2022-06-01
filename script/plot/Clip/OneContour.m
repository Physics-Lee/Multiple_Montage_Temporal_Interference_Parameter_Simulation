function [edgeSorted,node] = OneContour(TR4,TR)
%ONECONTOUR Summary of this function goes here
%   Detailed explanation goes here
[~, intSurface] = SurfaceIntersection(TR4,TR);
node = intSurface.vertices;
%% unsort edge
edge = intSurface.edges;
%% 
edgeSorted = SortEdge(edge);
end

