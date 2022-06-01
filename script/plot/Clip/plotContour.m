function h = plotContour(h,node,edge,dof,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
opt = varargin;
%% Contours C. make contour
figure(h);
hold on;
n = size(edge,1);
x = zeros(n+1,1);
y = zeros(n+1,1);
x(1:n) = node(edge(:,1),dof(1));
y(1:n) = node(edge(:,2),dof(2));
x(end) = x(1);
y(end) = y(1);
plot(x,y,opt{:});
end

