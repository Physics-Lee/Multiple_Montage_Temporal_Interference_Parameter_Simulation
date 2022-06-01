function [A,time_t] = Phase2CPU(input,U,thres)
%% load
num = U.num;
N = input.N;
volume = input.volume(1:N);
alpha = double(input.alpha);
if(alpha>=0)
    sumVolume = sum(volume);
end
A = single(zeros(num,1));
if length(size(input.E))==3
    E0 = input.E(1:N,:,:);
elseif length(size(input.E))==2
    E0 = input.E(1:N,:);
end
%%
t0 = tic;
for i = 1:num
    Ea = U.a.cu(i,1)*(E0(:,:,U.a.elec(i,1))-E0(:,:,U.a.elec(i,2)));
    Eb = U.b.cu(i,1)*(E0(:,:,U.b.elec(i,1))-E0(:,:,U.b.elec(i,2)));
    A0i = basic2(Ea,Eb);
    switch input.alpha
        case 0
            idx = A0i>thres;
            A(i) = sum(volume(idx))/sumVolume;
        case Inf
            A(i) = max(A0i);
        case -1
            A(i) = max(A0i);
        otherwise
            A(i) = (dot(A0i.^alpha,volume)/sumVolume).^(1/alpha);
    end
end
time_t = toc(t0);
disp(['Phase 2. CPU calculation in takes time : ' num2str(time_t) ' s...']);
end
