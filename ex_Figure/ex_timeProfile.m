%% setting path
dataRoot = 'I:\CXY_head';
d = dir(fullfile(dataRoot, '0*'));
Nsub = length(d);
ME = cell(Nsub,1);
simMarkPool = {'dACC_Volume';'dACC_Max';'dACC_Alpha2'};
Nalpha = length(simMarkPool);
otherAlphaPool = [0,Inf,2]';
y1 = zeros(Nsub,Nalpha);
y2 = zeros(Nsub,Nalpha);
for i = 1:Nsub
    for j = 1:Nalpha
        simDir = fullfile(dataRoot,d(i).name,'TI_sim_result',simMarkPool{j});
        timeProfileMat = fullfile(simDir,'timeProfile.mat'); 
        S = load(timeProfileMat);
        y1(i,j) = S.speedRatio;
        y2(i,j) = S.speedRatio2;
    end
end
y1 = y1(:,1);
y2(:,[2,3]) = y2(:,[3,2]);
y = [y1,y2];
yMean = mean(y,1);
err = std(y,[],1);
save(fullfile(dataRoot,'ex_timeProfile.mat'),'y1','y2');
%%
x_name = {'ROI phase','Other phase: '};
x = categorical(x_name);
x = reordercats(x,x_name);
%%
h = figure('visible','on');
hold on;
b = bar(x,y,.5);
x1 = nan(Nalpha, 2);
for i = 1:Nalpha
    x1(i,:) = b(i).XEndPoints;
end
errorbar(x1',y,err,'k','linestyle','none');
legendStr = {['0','Inf','2']);
 legend()
%%
ylabel('Speedup GPU/CPU');
titleStr = '4-electrode optimization in exhaustion method';
title(titleStr);
saveas(h,fullfile(dataRoot,[titleStr '.fig']));
