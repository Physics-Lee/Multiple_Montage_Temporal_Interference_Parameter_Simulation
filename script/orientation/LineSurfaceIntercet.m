function [V,faceIdx,idx] = LineSurfaceIntercet(ip,nt,node,face)
[distance,u,v] = raytrace(ip,nt,node,face);
pt = [1-u-v,u,v];
faceIdx0 = find(all(pt>0,2));
[~,i0] = min(abs(distance(faceIdx0)));
if isempty(i0)
    V = nan(3,1);
    faceIdx = 0;
    idx = false;
else
    faceIdx = faceIdx0(i0);
    V = pt(faceIdx,:);
    idx = true;
end
end

