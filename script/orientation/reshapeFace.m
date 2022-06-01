function [face] = reshapeFace(face0,b0)
%RESHAPEFACE Summary of this function goes here
%   Detailed explanation goes here
[~,k] = size(face0);
[m,n] = size(b0);
b1 = b0.';
f = face0(b1,:).';
face = permute(reshape(f,[k,n,m]),[2,1,3]);
end

