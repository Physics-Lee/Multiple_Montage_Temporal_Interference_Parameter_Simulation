function [a] = ROInt_CPU(E0,area0,C0,beta,method)
%ROINT Summary of this function goes here
%   Detailed explanation goes here
Nbeta = length(beta);
Nc = size(C0,1);
a = zeros(Nbeta,Nc);
for i = 1:Nc
    Ea1 = abs(E0(:,C0(i,1))-E0(:,C0(i,2)));
    Eb1 = abs(E0(:,C0(i,3))-E0(:,C0(i,4)));
    for j = 1:Nbeta
        Ea2 = beta(j)*Ea1;
        Eb2 = (2-beta(j))*Eb1;
        switch method
            case 0
                tmp = min([Ea2,Eb2],[],2);
                a(j,i) = 2*max(tmp);
        end
    end
end
end

