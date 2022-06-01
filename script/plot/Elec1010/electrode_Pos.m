function [Ele_array,Label] =  electrode_Pos()
% 根据等距的原理生成各个电极点的圆心位置，相应的Label按照电极生成的顺序

ele_array1 = [[-5:1:5].',zeros(11,1)];
label1 = {'T9' 'T7' 'C5' 'C3' 'C1' 'Cz' 'C2' 'C4' 'C6' 'T8' 'T10'};
ele_array2 = [zeros(10,1),[-5:1:4].'];
label2 = {'Iz' 'Oz' 'POz' 'Pz' 'CPz' 'Cz' 'FCz' 'Fz' 'AFz' 'Fpz'};

n = 20;
t = linspace(0,2*pi,n+1);
rho = 4.*ones(1,n+1);
[ele_array3(1,:),ele_array3(2,:)] = pol2cart(t,rho);
ele_array3 = ele_array3.';
ele_array3 = ele_array3(1:end-1,:);
label3 = {'T8' 'FT8' 'F8' 'AF8' 'Fp2' 'Fpz' 'Fp1' 'AF7' 'F7' 'FT7' 'T7'...
    'TP7' 'P7' 'PO7' 'O1' 'Oz' 'O2' 'PO8' 'P8' 'TP8'};

rho = 5.*ones(1,n+1);
[ele_array4(1,:),ele_array4(2,:)] = pol2cart(t,rho);
ele_array4 = ele_array4.';
ele_array4 = ele_array4([1:3 9:20],:);
label4 = {'T10' 'FT10' 'F10' 'F9' 'FT9' 'T9'...
    'TP9' 'P9' 'PO9' 'I1' 'Iz' 'I2' 'PO10' 'P10' 'TP10'};

L4array5 = ele_array3(8:14,:);
R4array5 = ele_array2(9:-1:3,:);
ele_array5 = (L4array5 + R4array5)./2;
label5 = {'AF3' 'F3' 'FC3' 'C3' 'CP3' 'P3' 'PO3'};

R4array6 = ele_array3([4:-1:1 20:-1:18],:);
L4array6 = ele_array2(9:-1:3,:);
ele_array6 = (L4array6 + R4array6)./2;
label6 = {'AF4' 'F4' 'FC4' 'C4' 'CP4' 'P4' 'PO4'};

L4array7 = L4array5(2:6,:);
R4array7 = ele_array5(2:6,:);
ele_array7 = (L4array7 + R4array7)./2;
label7 = {'F5' 'FC5' 'C5' 'CP5' 'P5'};

L4array8 = ele_array5(2:6,:);
R4array8 = R4array5(2:6,:);
ele_array8 = (L4array8 + R4array8)./2;
label8 = {'F1' 'FC1' 'C1' 'CP1' 'P1'};

L4array9 = L4array6(2:6,:);
R4array9 = ele_array6(2:6,:);
ele_array9 = (L4array9 + R4array9)./2;
label9 = {'F2' 'FC2' 'C2' 'CP2' 'P2'};

L4array10 = ele_array6(2:6,:);
R4array10 = R4array6(2:6,:);
ele_array10 = (L4array10 + R4array10)./2;
label10 = {'F6' 'FC6' 'C6' 'CP6' 'P6'};

Ele_array = [ele_array1;ele_array2;ele_array3;ele_array4;ele_array5;ele_array6;...
    ele_array7;ele_array8;ele_array9;ele_array10];
Label = [label1 label2 label3 label4 label5 label6 label7 label8 label9 label10].';

Rep = [];
for i = 1:size(Label,1)
   for j = i+1:size(Label,1)
       if strcmp(Label{i,1},Label{j,1})
          Rep  = [Rep j];
       end
   end
end
Rep = unique(Rep);
Ele_array(Rep,:) = [];
Label(Rep,:) = [];