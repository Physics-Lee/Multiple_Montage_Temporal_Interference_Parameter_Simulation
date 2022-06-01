function showU(U)
if size(U.a,1) == size(U.b,1)
    tableName = {'a.elec';'a.cu';'b.elec';'b.cu'};
    U2 = table(U.a.elec,U.a.cu,U.b.elec,U.b.cu,'VariableNames',tableName);
    disp(U2);
else
    disp('Frequence a...');
    disp(U.a);
    disp('Frequence b...');
    disp(U.b);
end
end

