function scale1000(dataRoot)
scale = 1000;
ERfile = fullfile(dataRoot,'Format','ROIsingle.mat');
ER = load(ERfile);
E0 = ER.E0/scale;
c0 = ER.c0;
save(ERfile,'E0','c0');
ECfile = fullfile(dataRoot,'Format','CORTEXsingle.mat');
EC = load(ECfile);
E0 = EC.E0/scale;
save(ECfile,'E0');
end

