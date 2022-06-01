function x_0 = find_the_wanted_electrode(directory,electrode_wanted,current_wanted)
% upload elec4.mat
temp = load(directory);
simulation_result_without_penalty = temp.T;

% 4 electrode
electrode_1 = simulation_result_without_penalty.elecA(:,1);
electrode_2 = simulation_result_without_penalty.elecA(:,2);
electrode_3 = simulation_result_without_penalty.elecB(:,1);
electrode_4 = simulation_result_without_penalty.elecB(:,2);
cu_1 = simulation_result_without_penalty.cuA(:,1);

% find wanted electrode
temp_1 = find(~(electrode_1 - electrode_wanted(1)));
temp_2 = find(~(electrode_2 - electrode_wanted(2)));
temp_3 = find(~(electrode_3 - electrode_wanted(3)));
temp_4 = find(~(electrode_4 - electrode_wanted(4)));
temp_5 = find(~(cu_1 - current_wanted));

for i = 1:length(temp_1)
    x_0 = temp_1(i);
    if my_find(temp_2,temp_1(i)) && my_find(temp_3,x_0) && my_find(temp_4,x_0) && my_find(temp_5,x_0)
        % fprintf('The electrode which you wants ranks %d\n',x_0);
        return;
    end
end