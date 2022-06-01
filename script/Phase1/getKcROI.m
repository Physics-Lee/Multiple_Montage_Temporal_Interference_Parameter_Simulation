function Kc = getKcROI(N,Nb,maxKc,blockSize)
%GETKC 此处显示有关此函数的摘要
%   此处显示详细说明
coef = 0.5;
g = gpuDevice(1);
Kc0 = round(g.AvailableMemory/4/Nb/N*coef/blockSize);
Kc = min([Kc0,maxKc]);
Kc = int32(Kc);
end

