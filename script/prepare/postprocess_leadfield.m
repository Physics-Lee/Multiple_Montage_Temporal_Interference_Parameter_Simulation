function LF = postprocess_leadfield(subname,datapath,ROI,Cortex)
% 对leadfield进行后处理，根据不同的ROI和Cortex的划分方法，提取相应的数据用于后续的仿真计算
% 输入：lf_path 字符串，leadfield的文件夹路径

%       ROI.method 字符串，划分ROI的具体方法
%                 ‘DK40’，皮层灰质中间层按照‘DK40’图谱划分脑区
%                 ‘MNI_Coord’,按照MNI坐标划分ROI，需要定义ROI的半径 ROI.r,单位为mm
%       ROI.name 字符串，ROI脑区的名称
%       ROI.multiple double,拓展ROI区域到mutiple倍面积（mutiple>1）,如果multiple<=1，则不进行拓展

%       Cortex.method 字符串，划分Cortex的具体方法
%                     'OutROI' ROI（拓展）区域以外的部分划分为Cortex
%                     'DK40' 使用DK40地图集指定某（些）脑区作为Cortex
%       ROI.name 字符串，ROI脑区的名称

% 输出：leadfield 结构体，包含后续计算需要的数据；后处理得到的 'leadfield.mat' 文件存储在 path4save 路径下

%% 文件读取
lf_path = fullfile(datapath,'leadfield');
currentdir = pwd;
cd(lf_path)
lffile = dir('*.hdf5');
if size(lffile,1) ~= 1
    disp('Wrong leadfield data, please check...');
    return;
end

lf = mesh_load_hdf5(lffile.name);
SurfMesh = lf(2).mesh;
gray_matter = mesh_extract_regions(SurfMesh, 'region_idx', [1 2]); %左右半球的灰质中间层
Cortex_mesh = mesh_extract_regions(gray_matter, 'region_idx', [1 2]);

%% 划分ROI
region_name = ROI.name;
switch ROI.method
    case 'DK40'
        % Load the atlas and define the brain region of interest
        [labels, snames] = subject_atlas(gray_matter, ...
            fullfile(datapath, ['m2m_' subname]), ROI.method);%DK40
        
        roi_idx = find(strcmpi(snames, region_name));
        node_idx = labels.node_data{end}.data == roi_idx;
    case 'MNI_Coord'
        coords_sub = mni2subject_coords(ROI.Coord_MNI, fullfile(datapath, ['m2m_' subname]));%坐标转换
        I_coords_sub = dsearchn(gray_matter.nodes,coords_sub);
        coords_sub = gray_matter.nodes(I_coords_sub,:);%邻近的网格顶点
        dist = sqrt(sum(bsxfun(@minus,gray_matter.nodes,coords_sub).^2,2));
        node_idx = dist < ROI.r;
    otherwise
        disp('Wrong ROI.method, please check...');
        return;
end

gray_matter.node_data{end+1}.data = int8(node_idx);
gray_matter.node_data{end}.name = region_name;
% mesh_show_surface(gray_matter, 'field_idx', region_name)

ROI_idx = gray_matter.node_data{end}.data == 1;
% LF.OutROI_idx = ~gray_matter.node_data{end}.data;

ROI_node_num = find(ROI_idx);
for i_facenode = 1:size(gray_matter.triangles,1)
    isROI(i_facenode) = all(ismember(gray_matter.triangles(i_facenode,1:3),ROI_node_num'));%三角形的三个顶点全部为ROI_node
end
gray_matter.triangle_regions(isROI',1) = 1234;
gray_matter = Region_edge_expansion(gray_matter,1234);
%

%% 提取ROI和Cortex的Index
%% 扩大ROI的边缘区域,这一步两种方法都要做
% 将ROI区域向外扩展的倍数，超出ROI的区域在计算过程中被“抠除”
% ROI区域为 1234，超出区域被标为 5678
gray_matter = ROI_expansion(gray_matter,ROI.multiple);

Cortex_mesh = mesh_extract_regions(gray_matter, 'region_idx', [1 2]);
[~,iaC,~] = intersect(gray_matter.nodes,Cortex_mesh.nodes,'rows');
LF.OutROI_idx = false(size(gray_matter.nodes,1),1);
LF.OutROI_idx(iaC) = true;

ROI_mesh = mesh_extract_regions(gray_matter, 'region_idx', 1234);
[~,iaR,~] = intersect(gray_matter.nodes,ROI_mesh.nodes,'rows');
LF.ROI_idx = false(size(gray_matter.nodes,1),1);
LF.ROI_idx(iaR) = true;

%% 如果multiple<=1，ROI不进行拓展，上述提取的ROI和Cortex边缘会在两个里面都取一次
% 将边缘从Cortex中去掉
TR_C = triangulation(Cortex_mesh.triangles,Cortex_mesh.nodes);
[~,Pf] = freeBoundary(TR_C);
[~,iaPf,~] = intersect(gray_matter.nodes,Pf,'rows');
LF.OutROI_idx(iaPf) = false;

switch Cortex.method
    case 'OutROI'
        LF.Cortex_coef = LF.OutROI_idx.*1;
    case 'DK40'  % 按照脑区选取的惩罚区域标签为 666
        for i_ca = 1:size(Cortex.penalty_areas,1)
            % Load the atlas and define the brain region of interest
            [labels, snames] = subject_atlas(gray_matter, ...
                fullfile(datapath, ['m2m_' subname]), 'DK40');%DK40
            region_name = Cortex.penalty_areas{i_ca,1};
            cor_idx = find(strcmpi(snames, region_name));
            node_idx_Cortex = labels.node_data{end}.data == cor_idx;
            
            gray_matter.node_data{end+1}.data = int8(node_idx_Cortex);
            gray_matter.node_data{end}.name = region_name;
            % mesh_show_surface(gray_matter, 'field_idx', region_name)
            
            Cor_idx = gray_matter.node_data{end}.data == 1;
            % LF.OutROI_idx = ~gray_matter.node_data{end}.data;
            
            Cor_node_num = find(Cor_idx);
            for i_facenode = 1:size(gray_matter.triangles,1)
                isCor(i_facenode) = all(ismember(gray_matter.triangles(i_facenode,1:3),Cor_node_num'));%三角形的三个顶点全部为Cor_node
            end
            gray_matter.triangle_regions(isCor',1) = 666;
            gray_matter = Region_edge_expansion(gray_matter,666);
        end
        
        Cortex_penalty_mesh = mesh_extract_regions(gray_matter, 'region_idx', 666);
        [~,iaC,~] = intersect(gray_matter.nodes,Cortex_penalty_mesh.nodes,'rows');
        LF.OutROI_penalty_idx = false(size(gray_matter.nodes,1),1);
        LF.OutROI_penalty_idx(iaC) = true;
        
        [CR,~,~] = intersect(Cortex_penalty_mesh.nodes,ROI_mesh.nodes,'rows');
        [~,iaCR,~] = intersect(gray_matter.nodes,CR,'rows');
        LF.OutROI_penalty_idx(iaCR) = false;%从Cortex中去掉与ROI重合的点
        
        LF.Cortex_coef = single(LF.OutROI_idx);
        LF.Cortex_coef(find(LF.OutROI_penalty_idx)) = Cortex.penalty_coef; %惩罚区域相应的惩罚系数，非惩罚区域系数为1
    case 'MNI_Coord'  % 按照MNI坐标选取的惩罚区域标签为 888
        for i_ca = 1:size(Cortex.penalty_areas,1)
            % Load the atlas and define the brain region of interest
            Coord_MNI_Cortex = Cortex.penalty_areas(i_ca,1:3);
            coords_sub_Cortex = mni2subject_coords(Coord_MNI_Cortex, fullfile(datapath, ['m2m_' subname]));%坐标转换
            I_coords_sub_Cortex = dsearchn(gray_matter.nodes,coords_sub_Cortex);
            coords_sub_Cortex = gray_matter.nodes(I_coords_sub_Cortex,:);%邻近的网格顶点
            dist = sqrt(sum(bsxfun(@minus,gray_matter.nodes,coords_sub_Cortex).^2,2));
            node_idx_Cortex = dist < Cortex.r;
            
            gray_matter.node_data{end+1}.data = int8(node_idx_Cortex);
            gray_matter.node_data{end}.name = region_name;
            % mesh_show_surface(gray_matter, 'field_idx', region_name)
            
            Cor_idx = gray_matter.node_data{end}.data == 1;
            % LF.OutROI_idx = ~gray_matter.node_data{end}.data;
            
            Cor_node_num = find(Cor_idx);
            for i_facenode = 1:size(gray_matter.triangles,1)
                isCor(i_facenode) = all(ismember(gray_matter.triangles(i_facenode,1:3),Cor_node_num'));%三角形的三个顶点全部为Cor_node
            end
            gray_matter.triangle_regions(isCor',1) = 888;
            gray_matter = Region_edge_expansion(gray_matter,888);
        end
        
        Cortex_penalty_mesh = mesh_extract_regions(gray_matter, 'region_idx', 888);
        [~,iaC,~] = intersect(gray_matter.nodes,Cortex_penalty_mesh.nodes,'rows');
        LF.OutROI_penalty_idx = false(size(gray_matter.nodes,1),1);
        LF.OutROI_penalty_idx(iaC) = true;
        
        [CR,~,~] = intersect(Cortex_penalty_mesh.nodes,ROI_mesh.nodes,'rows');
        [~,iaCR,~] = intersect(gray_matter.nodes,CR,'rows');
        LF.OutROI_penalty_idx(iaCR) = false;%从Cortex中去掉与ROI重合的点
        
        LF.Cortex_coef = single(LF.OutROI_idx);
        LF.Cortex_coef(find(LF.OutROI_penalty_idx)) = Cortex.penalty_coef; %惩罚区域相应的惩罚系数，非惩罚区域系数为1
    otherwise
        disp('Wrong Cortex.method, please check...');
        return;
end

LF.gray_matter = gray_matter;

%% 提取E_ROI,E_Cortex
LF.electrodes = lf(2).lf.properties.electrode_names; %电极名称
N = size(LF.electrodes,1); %电极数目

% VN = vertexNormal(TR); %E是nodedata VN是每个node位置的法向量
% LF.VN_ROI = VN(LF.ROI_idx,:);
% LF.VN_Cortex = VN(LF.OutROI_idx,:);

nodes_areas = mesh_get_node_areas(gray_matter);
LF.NA_ROI = single(nodes_areas(LF.ROI_idx,:)); % node areas
LF.NA_Cortex = single(nodes_areas(LF.OutROI_idx,:));

LF.E = zeros(size(lf(2).mesh.nodes,1),3,N);
LF.E_ROI = zeros(sum(LF.ROI_idx,1),3,N);
LF.E_Cortex = zeros(sum(LF.OutROI_idx,1),3,N);
for i = 2:N  %第一个电极是Cz，是参考电极，没有值
    LF.E(:,:,i) = lf(2).lf.data(:,:,i-1).';
end
LF.E = LF.E(1:size(gray_matter.nodes,1),:,:)./1000;%不除1000会显存溢出

for j = 2:N
    LF.E_ROI(:,:,j) = LF.E(LF.ROI_idx,:,j);
    LF.E_Cortex(:,:,j) = LF.E(LF.OutROI_idx,:,j);
end
LF.c0 = int32(nchoosek(1:N,4));
LF.E_ROI = single(LF.E_ROI);
LF.E_Cortex = single(LF.E_Cortex);

LF.Cortex_coef(LF.Cortex_coef == false) = [];
LF.Cortex_coef = repmat(LF.Cortex_coef,1,size(LF.E_Cortex,2),size(LF.E_Cortex,3));
LF.E_Cortex = LF.E_Cortex.*LF.Cortex_coef;%可以把Cortex.penalty设置为>1的数值，增大对想要排除的脑区的惩罚
% save(fullfile(path4save,'LF.mat'),'LF');
cd(currentdir);



