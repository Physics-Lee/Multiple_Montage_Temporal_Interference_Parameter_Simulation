function [Ea,Eb] = temp_proE(E0,U)
%PROE 此处显示有关此函数的摘要
%   此处显示详细说明
Ea = zeros(size(E0,[1,2]));
Eb = Ea;
%% a
Na = size(U.a,1);
for i = 1:Na
    Ea = Ea+ U.a.cu(i)*E0(:,:,U.a.elec(i));
end
%% b
Nb = size(U.b,1);
for i = 1:Nb
    Eb = Eb+ U.b.cu(i)*E0(:,:,U.b.elec(i));
end
end