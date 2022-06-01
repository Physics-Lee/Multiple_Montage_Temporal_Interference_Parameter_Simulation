% This function is used to screen the result of phase 1.
function [T1] = Phase1Screen(A_ROI,C,cu,thres,alpha)

switch alpha
    case Inf
        idx = find(A_ROI>thres);
    case 0
        idx = (1:numel(A_ROI))';
    otherwise
        idx = find(A_ROI>thres); % 这里的thres可以改为0.15
%         for i = 0.2:0.0001:0.3
%             idx = find(A_ROI>i);
%             if abs(length(idx)-10^5) <= 10^3
%                 break;
%             end
%         end
end

if ~isempty(idx)
    [i,j] = ind2sub(size(A_ROI),idx);
    tableName = {'elec';'cu';'ROI'};
    T1 = table(C(j,:),single(cu(i)),A_ROI(idx),'VariableNames',tableName);
else
    T1 = [];
end
disp(['The survived montage number is ' num2str(size(T1,1)) '.']);

end

