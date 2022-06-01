function U = temp_T2U(T)
elec_a = T.elecA(1:2);
elec_b = T.elecB(1:2);
cu_a = T.cuA;
cu_b = T.cuB;
U.a = t2u(elec_a,cu_a);
U.b = t2u(elec_b,cu_b);  
end
function U = t2u(elec,cu)
cu = [cu;-cu];
elec = elec(:);
tableName = {'elec';'cu'};
U = table(elec,cu,'VariableNames',tableName);
end
