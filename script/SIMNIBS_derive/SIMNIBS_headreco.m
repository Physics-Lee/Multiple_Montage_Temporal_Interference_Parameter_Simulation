function SIMNIBS_headreco(dataRoot,subMark)
%% SIMNIBS 运行说明
% 数据文件组织形式：被试的T1和T2结构像数据存储在以受试者编号等标识[subMark]命名的文件夹中，该文件夹为总的数据根目录 ‘dataRoot’
% 该根目录下应包含受试者的T1和T2像的 .nii 数据
% 并分别以‘[subMark]_TI.nii’'[subMark]_T2.nii'的形式命名
% 注意！！！ 'dataRoot'路径中不能含有空格，否则头模型建立会出错！！！
% 如果没有进行头模型建立的话先运行 headreco 进行头模型的创建，‘subMark’代表受试者的编号等标识，得到的头模型数据
% 'm2m_[subMark]'文件夹、 '[subMark].msh'文件、
% '[subMark]_T1ls_conform.nii.gz'压缩文件在‘dataRoot’根目录下
if exist(fullfile(dataRoot,subMark,[subMark '.msh']),'file')
    disp('The subject mesh has been created...');
    return;
else
    %% 头模型建立 headreco 从属于simnibs
    cd(fullfile(dataRoot,subMark));
    T1 = dir('*_T1.nii*');
    T2 = dir('*_T2.nii*');
    if isempty(T1)||isempty(T2)
        error('Wrong T1 or T2 data, please check!');
    end
    cd(fullfile(dataRoot,subMark));
    command = ['headreco all ' subMark ' ' T1.name ' ' T2.name];
    status = system(command);
end

