function [inputROI,inputOther,electrodes,mesh] = prepare_LF(cfg)
%% easy
t0 = tic;
dataRoot = cfg.dataRoot;
subMark = cfg.subMark;
simMark = cfg.simMark;
directory = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
inputFilePath = fullfile(dataRoot,subMark,'TI_sim_result');
if ~exist(inputFilePath ,'dir')
    mkdir(inputFilePath );
end
DataFile = fullfile(inputFilePath,['Data_' cfg.type '.mat']);

%% GMS or whole brain
switch cfg.type
    case 'tri'
        disp('Element type is triangle in gray matter middle layer ...');
    case 'tet'
        disp('Element type is tetraheron in gray and white matter in brain ...');
end

%% ?
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

%% easy
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

%% debug
try
    Volume_brain = Data.volume;
catch
    Volume_brain = Data.areas;
end

%% ROI index
disp('Define ROI region node index...');
cfg.type = 'tet';
ROI_idx = TargetTet(dataRoot,subMark,mesh,cfg.ROI); % TargetTet
if cfg.nt
    E_ROI = E_brain(ROI_idx,:);
else
    E_ROI = E_brain(ROI_idx,:,:);
end
volume_ROI = Volume_brain(ROI_idx);

%% Avoid
try 
    disp('Define Avoid region node index...');
    Avoid_idx = load([directory '\avoid_idx.mat']); % !!!
    Avoid_idx = Avoid_idx.avoid_idx;
    Avoid_idx = find(Avoid_idx);
    if cfg.nt
        E_brain(Avoid_idx,:) = E_brain(Avoid_idx,:) * cfg.Avoid.coef;
    else
        E_brain(Avoid_idx,:,:) = E_brain(Avoid_idx,:,:) * cfg.Avoid.coef;
    end
catch
    disp('avoid_idx.mat does not exist!!!');
end

% nt
if cfg.nt
    E_other = E_brain(~ROI_idx,:);
else
    E_other = E_brain(~ROI_idx,:,:);
end
volume_other = Volume_brain(~ROI_idx);

%% Padding leadfield with 128 memory size
[inputROI.E,inputROI.N] = zeroPadding(E_ROI,128);
inputROI.volume = zeroPadding(volume_ROI,128);
inputROI.alpha = cfg.ROI.alpha;
[inputOther.E,inputOther.N] = zeroPadding(E_other,128);
inputOther.volume = zeroPadding(volume_other,128);
inputOther.alpha = cfg.Other.alpha;
disp(['prepare GPU input takes ' num2str(toc(t0)) ' seconds.']);

end