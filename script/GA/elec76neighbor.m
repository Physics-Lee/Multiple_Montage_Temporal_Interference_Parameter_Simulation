function neighbours = elec76neighbor
%ELEC76NEIGHBOR Summary of this function goes here
%   Detailed explanation goes here
GA_path = fileparts(mfilename('fullpath'));
S1 = load(fullfile(GA_path,'biosemi64_neighb.mat'));
neighbours = S1.neighbours;
N1 = length(neighbours);
i = N1+1;
neighbours(i).label = 'F9';
neighbours(i).neighblabel = {'F7','AF7','FT7','FT9'}';
i = i+1;
neighbours(i).label = 'F10';
neighbours(i).neighblabel = {'F8','AF8','FT8','FT10'}';
i = i+1;
neighbours(i).label = 'FT9';
neighbours(i).neighblabel = {'F7','FT7','T7','F9','T9'}';
i = i+1;
neighbours(i).label = 'FT10';
neighbours(i).neighblabel = {'F8','FT8','T8','F10','T10'}';
i = i+1;
neighbours(i).label = 'T9';
neighbours(i).neighblabel = {'FT7','T7','TP7','FT9','TP9'}';
i = i+1;
neighbours(i).label = 'T10';
neighbours(i).neighblabel = {'FT8','T8','TP8','FT10','TP10'}';
i = i+1;
neighbours(i).label = 'TP9';
neighbours(i).neighblabel = {'T7','TP7','P7','T9','P9'}';
i = i+1;
neighbours(i).label = 'TP10';
neighbours(i).neighblabel = {'T8','TP8','P8','T10','P10'}';
i = i+1;
neighbours(i).label = 'PO9';
neighbours(i).neighblabel = {'P7','PO7','O1','P9','I1'}';
i = i+1;
neighbours(i).label = 'PO10';
neighbours(i).neighblabel = {'P8','PO8','O2','P10','I2'}';
i = i+1;
neighbours(i).label = 'I1';
neighbours(i).neighblabel = {'PO7','O1','Oz','PO9','Iz'}';
i = i+1;
neighbours(i).label = 'I2';
neighbours(i).neighblabel = {'PO8','O2','Oz','PO10','Iz'}';
N2 = length(neighbours);

%%
neighboursLabel = {neighbours.label}';
for i = (N1+1):N2
    for j = 1:length(neighbours(i).neighblabel)
        elec0 = neighbours(i).neighblabel{j};
        k = strcmp(elec0,neighboursLabel);
        if ~ismember(neighbours(i).label,neighbours(k).neighblabel)
            neighbours(k).neighblabel = [neighbours(k).neighblabel;neighbours(i).label];
        end
    end
end
%% test
% i = find(strcmp('AF7',{neighbours.label}));
% disp(neighbours(i).neighblabel);
end

