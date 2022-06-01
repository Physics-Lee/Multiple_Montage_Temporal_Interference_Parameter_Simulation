function [StimProtocol,gray_matter] = Elec_Parameter(U,leadfield)
% 由S3得到刺激电极位置和电流分配情况
% 输入：table2plot The table contains the electrodes info to plot
% 输出：StimProtocol 结构体，刺激电极位置和电流分配情况

StimProtocol.elecPair1 = U.a.elec;
StimProtocol.elecPair2 = U.b.elec;
StimProtocol.ElecPair1 = leadfield.electrodes(U.a.elec);
StimProtocol.ElecPair2 = leadfield.electrodes(U.b.elec);
StimProtocol.Current1 = U.a.cu;
StimProtocol.Current2 = U.b.cu;

%% 计算该种参数方案下的电场分布情况
E = leadfield.E;
E1 = E(:,:,StimProtocol.elecPair1);
E2 = E(:,:,StimProtocol.elecPair2);

EE1 = zeros(size(E1,1),size(E1,2));
EE2 = EE1;
for ie1 = 1:size(StimProtocol.ElecPair1,1)
    EE1 = EE1 + StimProtocol.Current1(ie1,1).*E1(:,:,ie1);
end
for ie2 = 1:size(StimProtocol.ElecPair2,1)
    EE2 = EE2 + StimProtocol.Current2(ie2,1).*E2(:,:,ie2);
end
TI = get_maxTI(EE1, EE2);
StimProtocol.TI_ROI = TI(leadfield.ROI_idx,1);
StimProtocol.TI_Cortex = TI(leadfield.OutROI_idx,1);
try
    StimProtocol.TI_penalty = TI(leadfield.OutROI_penalty_idx,1);
end

gray_matter = leadfield.gray_matter;
gray_matter.node_data = [];
gray_matter.node_data{1,1}.data = TI;
gray_matter.node_data{1,1}.name = 'TI';


