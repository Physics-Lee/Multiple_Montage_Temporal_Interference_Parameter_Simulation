function [Ea,Eb] = proE_nt(E0,U,i)
%PROE 此处显示有关此函数的摘要
%   此处显示详细说明
Ea = single(zeros(size(E0,1),1));
Eb = Ea;
%% a
for j = 1:U.a.elecNum
    Ea = Ea+ U.a.cu(i,j)*E0(:,U.a.elec(i,j));
end
%% b
for j = 1:U.b.elecNum
    Eb = Eb+ U.b.cu(i,j)*E0(:,U.b.elec(i,j));
end
Ea = abs(Ea);
Eb = abs(Eb);
end

