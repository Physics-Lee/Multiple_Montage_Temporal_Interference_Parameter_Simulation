disp('This script is to compare the speed of GPU and CPU framework.');
dataRoot = 'I:\CXY_head';
d = dir(fullfile(dataRoot, '0*'));
Nsub = length(d);
ME = cell(Nsub,1);
simMarkPool = {'dACC_Volume';'dACC_Max';'dACC_Alpha2'};
otherAlphaPool = [0,Inf,2]';
T_alpha = table(simMarkPool,otherAlphaPool);
cfg.dataRoot = dataRoot;
%% constant variable
elecPoolNum = 76;
elecNum = 4;
cu = (0.5+(0:20)*0.05)';
%% subject loop
for i = 1:Nsub
    subMark = d(i).name;
    disp(subMark);
    cfg.subMark = subMark;
    TIPSconfig;
    thres = cfg.thres;
    %% Check brain mesh
    SIMNIBS_headreco(dataRoot,subMark); % first time running for building mesh
    %% Prepare leadfield for GPU
    cfg.type = 'tet';
    [E_brain,Area_brain,electrodes,mesh] = prepare_LF(dataRoot,subMark,cfg);
    cmb = int32(nchoosek(1:size(electrodes,1),4));
    %% Define target brain regions
    disp('Define ROI region node index...');
    ROI_idx = TargetRegionIdx(dataRoot,subMark,mesh,cfg.ROI,'tet');
    if cfg.nt
        E_ROI = E_brain(ROI_idx,:);
    else
        E_ROI = E_brain(ROI_idx,:,:);
    end
    Area_ROI = Area_brain(ROI_idx);
    if cfg.Avoid.num>0
        disp('Define Avoid region node index...');
        Avoid_idx = TargetRegionIdx(dataRoot,subMark,mesh,'tet');
        if cfg.nt
            E_brain(Avoid_idx,:) = E_brain(Avoid_idx,:) * cfg.Avoid.coef;
        else
            E_brain(Avoid_idx,:,:) = E_brain(Avoid_idx,:,:) * cfg.Avoid.coef;
        end
    end
    if cfg.nt
        E_other = E_brain(~ROI_idx,:);
    else
        E_other = E_brain(~ROI_idx,:,:);
    end
    Area_other = Area_brain(~ROI_idx);
    %% Padding leadfield with 128 memory size
    [inputROI.E,inputROI.N] = zeroPadding(E_ROI,128);
    inputROI.volume = zeroPadding(Area_ROI,128);
    inputROI.alpha = cfg.ROI.alpha;
    [inputOther.E,inputOther.N] = zeroPadding(E_other,128);
    inputOther.volume = zeroPadding(Area_other,128);
    %     inputOther.alpha = cfg.Other.alpha;
    %% step 1: ROI CPU VS GPU
    disp('Phase 1. Calculate the Elf of ROI in Max form for screen.');
    persentCPU = 0.01;
    cmbCPU = cmb(1:round(persentCPU*size(cmb,1)),:);
    [T1_c,~,time_t_CPU] = Phase1WrapperCPU(inputROI,cmbCPU,cu,thres);%33.1904 s
    [T1,~,time_t_GPU] = Phase1Wrapper(inputROI,cmb,cu,thres); % 0.039433
    speedRatio = time_t_CPU/time_t_GPU/persentCPU;
    disp(['Phase 1. The speed ratio between GPU and CPU is ' num2str(speedRatio) ' .']);
    disp(['The survived montage number is ' num2str(size(T1,1)) '.']);
    disp(T1(1:5,:));
    %% step 2 : Other region
    disp('Phase 2. Calculate the Elf in Other brain region with screened parameters.');
    %% Other Alpha loop
    for j = 1:size(T_alpha,1)
        cfg.Other.alpha = T_alpha.otherAlphaPool(j);
        inputOther.alpha = cfg.Other.alpha;
        cfg.simMark = T_alpha.simMarkPool{j};
        simMark =  cfg.simMark;
        simDir = fullfile(dataRoot,subMark,'TI_sim_result',cfg.simMark);
        if ~isfolder(simDir)
            disp(['The new directory with simMark ' simMark ' creates.']);
            mkdir(simDir);
        end
        save(fullfile(simDir,'cfg.mat'),'cfg');
        timeProfileMat = fullfile(simDir,'timeProfile.mat');
        start = datestr(now);
        diaryFile = name4diary(simDir); % file name depend on time
        diary(diaryFile);
        diary on
        %% Speedup GPU/CPU
        N2 = size(T1,1);
        N2_test_CPU = 300; % very few montages for test speed, too slow T_T
        N2_test_GPU = round(0.1*N2); % few montages for test speed, but not too few, could be much bigger than CPU
        U4_test_CPU = T2U(T1(1:N2_test_CPU,:));
        U4_test_GPU = T2U(T1(1:N2_test_GPU,:));
        [A_Other_test_CPU,time_t_test_CPU2] = Phase2CPU(inputOther,U4_test_CPU,thres);
        [A_Other_test_GPU,time_t_test_GPU2] = Phase2Wrapper(inputOther,U4_test_GPU,thres);
        speedRatio2 = time_t_test_CPU2/N2_test_CPU/(time_t_test_GPU2/N2_test_GPU);
        disp(['Phase 2. The speed ratio between GPU and CPU is ' num2str(speedRatio2) ' .']);
        save(timeProfileMat,'speedRatio','speedRatio2');
        %% plot
        h = figure('visible','off');
        x_name = {'ROI phase','Other phase'};
        x = categorical(x_name);
        x = reordercats(x,x_name);
        y = [speedRatio,speedRatio2];
        b = bar(x,y,.4);
        ylabel('Speedup GPU/CPU');
        titleStr = '4-electrode optimization in exhaustion method';
        title(titleStr);
        saveas(h,fullfile(simDir,[titleStr '.fig']));
        saveas(h,fullfile(simDir,[titleStr '.bmp']));
        delete(h)
        %% step 3 : 4 electrode, Exhaustion VS Genetic Algorithm
        t0 = tic;
        [T_GA,yMax,yMean] = GA_elec4(inputROI,inputOther,T1,cfg.Other.alpha,thres,elecPoolNum);
        time_t_GA = toc(t0);
        disp(['Phase 2. Genetic Algorithm takes time : ' num2str(time_t_GA) ' s...']);
        %%
        h = figure('visible','off');
        x = 1:length(yMax);
        plot(x,yMax,x,yMean);
        xlabel('Generation');
        ylabel('Optimal objective value');
        titleStr = '4-electrode Genetic Algorithm';
        title(titleStr);
        saveas(h,fullfile(simDir,[titleStr '.fig']));
        saveas(h,fullfile(simDir,[titleStr '.bmp']));
        delete(h)
        %% Exhaustion
        t0 = tic;
        U4 = T2U(T1);
        [A_Other,time_t_GPU2] = Phase2Wrapper(inputOther,U4,thres); %
        T_Ex = SortObject(U4,T1.ROI,A_Other,cfg.Other.alpha,thres);
        time_t_Ex = toc(t0);
        disp(['Phase2. Exhaustion Method takes time : ' num2str(time_t_Ex) ' s...']);
        speedRatio3 = time_t_Ex/time_t_GA;
        disp(['Phase 2. The speed ratio between Exhaustion Method and Genetic Algorithm is ' num2str(speedRatio3) ' .']);
        disp('Genetic Algorithm :');
        disp(T_GA(1:10,:));
        disp('Exhaustion Method :');
        disp(T_Ex(1:10,:));
        %% plot
        h = figure('visible','off');
        x_name = {'Exhaustion','Genetic Algorithm'};
        x = categorical(x_name);
        x = reordercats(x,x_name);
        y = [time_t_Ex,time_t_GA];
        bar(x,y,.4);
        ylabel('Time consumption (Seconds)');
        titleStr = 'Time profile in 4-electrode montage';
        title(titleStr);
        saveas(h,fullfile(simDir,[titleStr '.fig']));
        saveas(h,fullfile(simDir,[titleStr '.bmp']));
        delete(h);
        %% step 4 : 8 electrode Genetic Algorithm
        t0 = tic;
        [T_GA8,yMax8,yMean8] = GA_elec8(inputROI,inputOther,T_Ex,cfg.Other.alpha,thres,elecPoolNum);
        time_t_GA8 = toc(t0);
        disp(['Phase 3. 8-electrode Genetic Algorithm takes time : ' num2str(time_t_GA8) ' s...']);
        speedRatio4 = time_t_GA8/time_t_GA;
        disp(['The speed ratio in GA between 8 electrodes and 4 electrodes is ' num2str(speedRatio4) ' .']);
        save(timeProfileMat,'time_t_GA','time_t_Ex','speedRatio3','time_t_GA8','speedRatio4','-append');
        save(timeProfileMat,'T_Ex','T_GA','yMax','yMean','T_GA8','yMax8','yMean8','-append');
        %%
        h = figure('visible','off');
        x = 1:length(yMax8);
        plot(x,yMax8,x,yMean8);
        xlabel('Generation');
        ylabel('Optimal objective value');
        titleStr = '4-electrode Genetic Algorithm';
        title(titleStr);
        saveas(h,fullfile(simDir,[titleStr '.fig']));
        saveas(h,fullfile(simDir,[titleStr '.bmp']));
        delete(h);
        %%
        h = figure('visible','off');
        x = [4,8];
        y = [time_t_GA,time_t_GA8];
        bar(x,y,.4);
        xlabel('Electrode number');
        ylabel('Time consumption (Seconds)');
        titleStr = 'Time profile in Genetic Algorithm';
        title(titleStr);
        saveas(h,fullfile(simDir,[titleStr '.fig']));
        saveas(h,fullfile(simDir,[titleStr '.bmp']));
        delete(h);
        %% log off
        disp(['Start time : ' start])
        disp(['End time : ' datestr(now)])
        diary off
    end
end
