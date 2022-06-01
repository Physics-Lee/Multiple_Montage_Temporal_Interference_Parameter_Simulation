function [face] = getSurf(elem)
face = [elem(:,[1 2 3]);elem(:,[1 2 4]);elem(:,[1 3 4]);elem(:,[2 3 4])];
face = sort(face,2);
face = sortrows(face);
duploc = find(all(diff(face) == 0,2));
face([duploc;duploc + 1],:) = [];
end


