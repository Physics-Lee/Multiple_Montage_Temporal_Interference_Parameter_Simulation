function [es,eRemain,ends_pool] = SortEdgeGiveEnd(e0,ends_pool)
%SORTEDGEGIVEEND Summary of this function goes here
%   Detailed explanation goes here
%%
if isempty(ends_pool)
    end0 = e0(1,1);
else
    end0 = ends_pool(1);
    ends_pool = setdiff(ends_pool,end0);
end
    eRemain = e0;
    es = zeros(size(e0));
    [sub1,sub2]=ind2sub(size(e0),find(e0==end0));
    %% first edge of es
    es(1,1)=e0(sub1(1),sub2(1));
    es(1,2)=e0(sub1(1),mod(sub2(1),2)+1);
    eRemain(sub1(1),:)=[];
    %% i from 2
    for i=2:size(e0,1)
        key = es(i-1,2);
        if key==end0
            es(i:end,:) = [];
            break;
        elseif ismember(key,ends_pool)
            es(i:end,:) = [];
            ends_pool = setdiff(ends_pool,key);
            break;
        else
            [sub1,sub2]=ind2sub(size(eRemain),find(eRemain==key));
            es(i,1)= key;
            es(i,2)= eRemain(sub1(1),mod(sub2(1),2)+1);
            eRemain(sub1(1),:)=[];
        end
    end
end


