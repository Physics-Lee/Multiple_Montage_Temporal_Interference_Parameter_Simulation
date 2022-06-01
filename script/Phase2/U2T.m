function T = U2T(U,varargin)
tableName = {'Ratio';'ROI';'Other';'elecA';'elecB';'cuA';'cuB'};
N = U.num;
if nargin == 1
    R = single(zeros(N,1));
    A_ROI = single(zeros(N,1));
    A_Other = single(zeros(N,1));
elseif nargin == 4
    R = varargin{1};
    A_ROI = varargin{2};
    A_Other = varargin{3};
end
cuA = single(U.a.cu)*0.05;
cuB = single(U.b.cu)*0.05;
T = table(R,A_ROI,A_Other,U.a.elec,U.b.elec,cuA,cuB,'VariableNames',tableName);
end

