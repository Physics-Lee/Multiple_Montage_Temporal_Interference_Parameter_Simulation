function [TR1,node_idx] = simpleTR(TR)
node_idx = unique(TR.ConnectivityList);
node1 = TR.Points(node_idx,:);
node_idx1 = 1:size(node1,1);
face1 = changem1(TR.ConnectivityList,node_idx1',node_idx);%180s
warning('off', 'all')
if(~isa(face1,'double'))
    TR1 = triangulation(double(face1),node1);
else
    TR1 = triangulation(face1,node1);
end
end