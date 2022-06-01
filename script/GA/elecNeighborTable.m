function T = elecNeighborTable
%% path
GA_path = fileparts(mfilename('fullpath'));
neighbours = elec76neighbor;
S2 = load(fullfile(GA_path,'LFelectrodes.mat'));
elecName = deblank(S2.LFelectrodes);
N = length(elecName);
idx = (1:N)';
neighbourIdx = cell(N,1);
neighbourName = cell(N,1);
for i = 1:length(neighbours)
    ii = find(strcmp(neighbours(i).label,elecName));
    neighbourName{ii} = neighbours(i).neighblabel;
    neighbourIdx{ii} = find(ismember(elecName,neighbourName{ii}));
end
T = table(elecName,idx,neighbourName,neighbourIdx);
end
