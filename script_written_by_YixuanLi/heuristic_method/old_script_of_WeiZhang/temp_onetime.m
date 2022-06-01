function D0 = temp_onetime(input,U) % input是？ U是？
%% get E
N = input.N;
if length(size(input.E))==3
%     E0 = input.E(1:N,:,:);
    [Ea,Eb] = temp_proE(input.E(1:N,:,:),U);
    D0 = temp_basic2(Ea,Eb);
elseif length(size(input.E))==2
    E0 = input.E(1:N,:);
    [Ea,Eb] = proE_nt(E0,U);
    D0 = 2*min(Ea,Eb); %% basic nt
end