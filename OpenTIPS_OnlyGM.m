% this script is a variation of OpenTIPS.m

function T = OpenTIPS_OnlyGM(varargin)
if nargin == 1
    cfg = varargin{1};
elseif nargin == 0
    try
        cfg = evalin('base','cfg');
    catch
        error('Please configuration before running OpenTIPS.');
    end
end
dataRoot = cfg.dataRoot;
subMark = cfg.subMark;
simMark = cfg.simMark;
elecNum = cfg.elecNum;
optimalMethod = cfg.optimalMethod;
%%
switch elecNum
    case 4
        switch optimalMethod
            case 'Exhaustion'
                disp('Use Exhaust Algorithm to optimize 4 electrodes montages.');
            case 'Genetic Algorithm'
                disp('Use Genetic Algorithm to optimize 4 electrodes montages.');
            otherwise
                error('Please specify optimal algorithm!');
        end
    case 8
        optimalMethod = 'Genetic Algorithm';
        disp('Use Genetic Algorithm to optimize 8 electrodes montages.');
        try
            elec4ResultFile = dir(fullfile(dataRoot,subMark,'TI_sim_result',simMark,'*elec4*.mat'));
            S4 = load(fullfile(elec4ResultFile(1).folder,elec4ResultFile(1).name));
            disp(['Reading 4 electrodes result from file ' elec4ResultFile(1).name ' .']);
            if isfield(S4,'T2')
                T2 = S4.T2;
            elseif isfield(S4,'T')
                T2 = S4.T;
            end
        catch
            error('Please optimize 4 electrodes montages firstly as seed.');
        end
    otherwise
        error('Only 4 electrodes and 8 electrodes supported by now.');
end
%% Check brain mesh
SIMNIBS_headreco(dataRoot,subMark); % first time running for building mesh
%% Check output directory
simDir = fullfile(dataRoot,subMark,'TI_sim_result',simMark);
if ~isfolder(simDir)
    disp(['The new directory with simMark ' simMark ' creates.']);
    mkdir(simDir);
end
save(fullfile(simDir,'cfg.mat'),'cfg');
%% log on
start = datestr(now);
diaryFile = name4diary(simDir); % file name depend on time
diary(diaryFile);
diary on
%% Prepare leadfield for GPU
[inputROI,inputOther,electrodes] = prepare_LF_OnlyGM(cfg);
%% threshold
thres = cfg.thres;
elecPoolNum = 76;
%% main process
switch elecNum
    case 4
        %% step 1: ROI screen
        disp('Phase 1. Calculate the Elf of ROI in Max form for screen.');
        cu = (0.5+(0:20)*0.05)';
        cmb = int32(nchoosek(1:size(electrodes,1),4));
        [A_ROI,cmb3] = Phase1Wrapper(inputROI,cmb,cu,thres);
        T1 = Phase1Screen(A_ROI,cmb3,cu,thres,inputROI.alpha);
        U4 = T2U(T1);
        %% step 2: Other sort
        switch optimalMethod
            case 'Exhaustion'
                disp('Phase 2. Calculate the Elf in Other brain region with screened parameters.');
                A_Other = Phase2Wrapper(inputOther,U4,thres);
                T = SortObject(U4,T1.ROI,A_Other,cfg.Other.alpha,thres);
            case 'Genetic Algorithm'
                T = GA_elec4(inputROI,inputOther,T1,cfg.Other.alpha,thres,elecPoolNum);
        end
    case 8
        T = GA_elec8(inputROI,inputOther,T2,cfg.Other.alpha,thres,elecPoolNum);
end
disp(T(1:10,:));
saveFile = fullfile(simDir,['elec' num2str(cfg.elecNum) '_' optimalMethod '.mat']);
save(saveFile,'optimalMethod','elecNum','T','electrodes');
%% log off
disp(['Start time : ' start])
disp(['End time : ' datestr(now)])
diary off