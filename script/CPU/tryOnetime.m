function T = tryOnetime(inputROI,inputOther,U)
A_ROI = Onetime(inputROI,U);
A_Other = Onetime(inputOther,U);
R = A_ROI/A_Other;
tableName = {'Ratio';'ROI';'Other'};
T = table(R,A_ROI,A_Other,'VariableNames',tableName);
end


