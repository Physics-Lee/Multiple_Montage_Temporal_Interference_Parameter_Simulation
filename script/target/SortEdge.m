function es = SortEdge(e0)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
eRemain = e0;
es = cell(0,1);
i = 1;
%%
[B,BG] = groupcounts(e0(:));
ends_pool = BG(B==1);
while size(eRemain,1)>0
    [es{i},eRemain,ends_pool] = SortEdgeGiveEnd(eRemain,ends_pool);
    i = i+1;
end
n = cellfun(@length,es,'un',1);
[~,k] = sort(n,'d');
es = es(k);
end

