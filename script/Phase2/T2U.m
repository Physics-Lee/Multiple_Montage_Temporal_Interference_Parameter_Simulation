function U = T2U(T)
U.num = size(T,1);
if ismember('cu', T.Properties.VariableNames) % for old version
    U.a.elecNum = 2;
    U.b.elecNum = 2;
    U.a.elec = T.elec(:,1:2);
    U.b.elec = T.elec(:,3:4);
    cu = abs(T.cu);
    U.a.cu = [cu,-cu];
    U.b.cu = [2 - cu,-2 + cu];
else
    U.a.elecNum = size(T.elecA,2);
    U.b.elecNum = size(T.elecB,2);
    U.a.elec = T.elecA;
    U.b.elec = T.elecB;
    U.a.cu = T.cuA;
    U.b.cu = T.cuB;
end
end

