function [D,time_t,varargout] = Onetime(input,U,thres)
%% get E
num = U.num;
N = input.N;
volume = input.volume(1:N);
if(input.alpha>=0)
    sumVolume = sum(volume);
end
if length(size(input.E))==3
    E0 = input.E(1:N,:,:);
elseif length(size(input.E))==2
    E0 = input.E(1:N,:);
end
D = single(zeros(num,1));
%%
if nargout == 3
    varargout{1} = single(zeros(N,num));
elseif nargout>3
    error('Too many output argument!');
end
t0 = tic;
for i = 1:num
    if length(size(input.E))==3
        [Ea,Eb] = proE(E0,U,i);
        D0i = basic2(Ea,Eb);
    elseif length(size(input.E))==2
        [Ea,Eb] = proE_nt(E0,U,i);
        D0i = 2*min(Ea,Eb); %% basic nt
    end
    %% get optimal object
    switch input.alpha
        case 0
            idx = D0i>thres;
            D(i) = sum(volume(idx))/sumVolume;
        case Inf
            D(i) = max(D0i);
        case -1
            D(i) = max(D0i);
        otherwise
            alpha = double(input.alpha);
            D(i) = (dot(D0i.^alpha,volume)/sumVolume).^(1/alpha);
    end
    if nargout == 3
        varargout{1}(:,i) = D0i;
    end
end
time_t = toc(t0);
disp(['CPU calculation in takes time : ' num2str(time_t) ' s...']);
end