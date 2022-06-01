function T = SortObject(U,A_ROI,A_Other,otherAlpha,thres)
%CORTEXTABLE 此处显示有关此函数的摘要
%   此处显示详细说明
tableName = {'Ratio';'ROI';'Other';'elecA';'elecB';'cuA';'cuB'};
switch otherAlpha
    case 0 % volume
        R = A_Other;
        T = table(R,A_ROI,A_Other,U.a.elec,U.b.elec,U.a.cu,U.b.cu,'VariableNames',tableName);
        idx = A_ROI<thres;
        T(idx,:) = [];
        T = sortrows(T,1,'a');
    case -1 % max
        R = A_ROI./A_Other;  
        R(isnan(R))=0;
        T = table(R,A_ROI,A_Other,U.a.elec,U.b.elec,U.a.cu,U.b.cu,'VariableNames',tableName);
        idx = A_ROI<thres;
        T(idx,:) = [];
        T = sortrows(T,1,'d');
    otherwise
        R = A_ROI./A_Other;
        R(isnan(R))=0;
        T = table(R,A_ROI,A_Other,U.a.elec,U.b.elec,U.a.cu,U.b.cu,'VariableNames',tableName);
        idx = A_ROI<thres;
        T(idx,:) = [];
        T = sortrows(T,1,'d');
end
end

