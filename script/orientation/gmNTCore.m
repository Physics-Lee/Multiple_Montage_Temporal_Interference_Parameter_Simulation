function Vcart = gmNTCore(TR_mid,TR_GM,TR_WM,nt,ip)
%GMNT Summary of this function goes here
%   Detailed explanation goes here
N = size(TR_mid.ConnectivityList,1);
TR{1} = TR_GM; % j =1, GM
TR{2} = TR_WM; % j =2, WM
k = 30;
ipfc = cell(2,1);
IDf = zeros(N,k,2);
for j = 1:2
    ipfc{j} = incenter(TR{j});
    IDf(:,:,j) = knnsearch(ipfc{j},ip,'K',k);
end
%%
faceIdx = zeros(N,2);
Vbary = zeros(N,3,2);
idx = false(N,2);
%% parfor
N1 = N;
% par(4);
for j = 1:2
    TRj = TR{j};
    nodej = TRj.Points;
    facej = reshapeFace(TRj.ConnectivityList,IDf(:,:,j));
    for i = 1:N1
        [Vbary(i,:,j),faceIdx(i,j),idx(i,j)] = LineSurfaceIntercet(ip(i,:),nt(i,:),nodej,facej(:,:,i));
    end
end
%%
i10 = (1:N).';
Vcart = zeros(N,3,2);
for j = 1:2
    row = i10(idx(:,j));
    tmp = IDf(:,:,j);
    ind = sub2ind(size(tmp),row,faceIdx(idx(:,j),j));
    Vcart(idx(:,j),:,j) = barycentricToCartesian(TR{j},tmp(ind),Vbary(idx(:,j),:,j)); 
end
for j = 1:2
    Vcart(~idx(:,j),:,j) = ip(~idx(:,j),:);
end
%% plot check
% i = 1;
% r = 10;
% ip1 = ip(i,:) + r*nt(i,:);
% ip2 = ip(i,:) - r*nt(i,:);
% Vcart_i = nan(2,3);
% figure;
% hold on; 
% plot3v(ip(i,:),'r*');
% plot3v([ip1;ip(i,:);ip2],'b-');
% TR_local = cell(1,2);
% for j = 1:2
%     TR_local{j} = triangulation(TR{j}.ConnectivityList(IDf(i,:,j),:),TR{j}.Points);
%     showTR(TR_local{j});
% %     [Vbary_i,faceIdx0] = LineSurfaceIntercet(ip(i,:),nt(i,:),TR_local{j}.Points,TR_local{j}.ConnectivityList);
%     if idx(i,j)
%         faceIdx_i = IDf(i,faceIdx(i,j),j);
% %         Vcart_i(j,:) = barycentricToCartesian(TR{j},faceIdx_i,Vbary_i);
%         plot3v(Vcart(i,:,j),'g*');
%         plot3v(TR_local{j}.Points(TR_local{j}.ConnectivityList(faceIdx(i,j),:),:),'k*');
%     end
% end



