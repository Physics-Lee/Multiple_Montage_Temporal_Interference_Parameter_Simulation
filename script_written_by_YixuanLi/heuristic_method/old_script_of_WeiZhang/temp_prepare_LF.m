function [E_brain,Volume_brain,electrodes,mesh] = temp_prepare_LF(dataRoot,subMark,cfg)
inputFilePath = fullfile(dataRoot,subMark,'TI_sim_result');
if ~exist(inputFilePath ,'dir')
    mkdir(inputFilePath );
end
DataFile = fullfile(inputFilePath,['Data_' cfg.type '.mat']);
%%
switch cfg.type
    case 'tri'
        disp('Element type is triangle in gray matter middle layer ...');
    case 'tet'
        disp('Element type is tetraheron in gray and white matter in brain ...');
end
%%
if exist(DataFile,'file')
    disp('Already existed input data for GPU, omit producing input mat file.');
    S = load(DataFile);
    Data = S.Data;
    mesh = S.mesh;
else
    disp('The first time prepare input data for GPU.');
    t0 = tic;
    switch cfg.type
        case 'tri'
            [Data,mesh] = LFSurf(dataRoot,subMark);
        case 'tet'
            [Data,mesh] = LFTet(dataRoot,subMark);
    end
    save(DataFile,'Data','mesh','-v7.3');
    disp(['Prepare with ' cfg.type ' type using ' num2str(toc(t0)) 'seconds.']);
end
%%
electrodes = Data.electrodes;
%% nt
if cfg.nt
    disp('The orientation of tetrhedron elements is taken into account.')
    WMntFile = fullfile(dataRoot,subMark,'orientation','nt_elem_WM.mat');
    WM = load(WMntFile);
    GMntFile = fullfile(dataRoot,subMark,'orientation','nt_elem_GM.mat');
    GM = load(GMntFile);
    nt = single([WM.nt_elem_WM;GM.nt_elem_GM]);
    E_brain = single(zeros(size(Data.E,1),size(Data.E,3)));
    for i = 1:size(Data.E,3)
        E_brain(:,i) = dot(Data.E(:,:,i),nt,2);
    end
else
    E_brain = Data.E;
end
try 
    Volume_brain = Data.volume;
catch
    Volume_brain = Data.areas;
end

