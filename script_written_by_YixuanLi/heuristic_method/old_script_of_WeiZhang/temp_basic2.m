function r = temp_basic2(Ea,Eb) % 输入是两个E矢量，输出是Elf
% basic problem of TI "projection min max" problem
% ensure alpha < pi/2
if ~isequal(size(Ea),size(Eb))
    error('input Ea,Eb size unequal...');
end
r = single(zeros(size(Ea,1),1));
idx = dot(Ea,Eb,2)<0;
Eb(idx,:) = -Eb(idx,:);
absEa=sqrt(sum(Ea.^2,2));
absEb=sqrt(sum(Eb.^2,2));
cosalpha=dot(Ea,Eb,2)./(absEa.*absEb);
alpha = 1;
beta = 1;
da = alpha*Ea;
db = beta*Eb;
norma = absEa*alpha;
normb = absEb*beta;
% ensure Ea>Eb
idx = normb>norma;
tmp = da;
da(idx,:) = db(idx,:);
db(idx,:) = tmp(idx,:);
tmp = norma;
norma(idx,:) = normb(idx,:);
normb(idx,:) = tmp(idx,:);
% if Eb<Ea*cosalpha
idx =  normb< norma.* cosalpha;
r(idx) = 2*normb(idx);
% else Eb<Ea*cosalpha
dc = da(~idx,:)-db(~idx,:);
dcross = cross(db(~idx,:),dc,2); % cross是求叉乘的
t1 = sum(dcross.^2,2);
t2 = sum(dc.^2,2);
r(~idx) = 2*sqrt(t1)./sqrt(t2);
end

