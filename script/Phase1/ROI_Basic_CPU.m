function A = ROI_Basic_CPU(E,elec,cu,alpha,volume,thres)  
if(alpha>=0)
    sumVolume = sum(volume);
end    
Ea0 = E(:,:,elec(1))-E(:,:,elec(2));       
Eb0 = E(:,:,elec(3))-E(:,:,elec(4));
Ncu = length(cu);
N = size(E,1);
A = single(zeros(Ncu,1));
Ai = single(zeros(N,1));
%% ensure alpha < pi/2
idx = dot(Ea0,Eb0,2)<0;
Eb0(idx,:) = -Eb0(idx,:);
normA0=sqrt(sum(Ea0.^2,2));
normB0=sqrt(sum(Eb0.^2,2));
cosalpha=dot(Ea0,Eb0,2)./(normA0.*normB0);
%% loop over current setting
for i = 1:Ncu
    cuA = cu(i);
    cuB = 2-cuA;
    Ea = cuA*Ea0;
    Eb = cuB*Eb0;
    normA = normA0*cuA;
    normB = normB0*cuB;
    %% ensure Ea>Eb
    idx = normB>normA;
    tmp = Ea;
    Ea(idx,:) = Eb(idx,:);
    Eb(idx,:) = tmp(idx,:);
    tmp = normA;
    normA(idx,:) = normB(idx,:);
    normB(idx,:) = tmp(idx,:);
    %% if Eb<Ea*cosalpha
    idx =  normB< normA.* cosalpha;
    Ai(idx) = 2*normB(idx);
    %% else Eb<Ea*cosalpha
    Ec = Ea(~idx,:)-Eb(~idx,:);
    Ecross = cross(Eb(~idx,:),Ec,2);
    t1 = sum(Ecross.^2,2);
    t2 = sum(Ec.^2,2);
    Ai(~idx) = 2*sqrt(t1)./sqrt(t2);
    %% get max or sum
    switch alpha
        case 0
            idx = Ai>thres;
            A(i) = sum(volume(idx))/sumVolume;
        case Inf
            A(i) = max(Ai);
        case -1
            A(i) = max(Ai);
        otherwise
            alphaD = double(alpha);
            A(i) = (dot(Ai.^alphaD,volume)/sumVolume).^(1/alphaD);
    end
end

