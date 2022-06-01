function compileTI(src_prefix)
pathSrc = fileparts(mfilename('fullpath'));
src = fullfile(pathSrc,[src_prefix '.cu']);
%% get cuda ver
cudaRoot = 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA';
d = dir(fullfile(cudaRoot,'v*'));
vName = {d.name};
vNum = cellfun(@(x) str2num(x(2:end)),vName);
[~,i] = max(vNum);
cudaVer = vName{i};
disp(['Compile using CUDA version ' cudaVer ' .']);
%%
path1 = ['-I' fullfile(cudaRoot,cudaVer,'include')];
libpath = ['-L' fullfile(cudaRoot,cudaVer,'lib','x64')];
lib1 = ['-l' 'cusparse.lib'];
lib2 = ['-l' 'cublas.lib'];
pNow = pwd;
cd(pathSrc);
mexcuda(path1,libpath,lib1,lib2,src);
cd(pNow);
end
