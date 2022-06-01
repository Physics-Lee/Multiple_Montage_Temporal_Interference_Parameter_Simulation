function C0 = FreeC0(occupiedElec,elecNum)
%FREEC0 Summary of this function goes here
%   Detailed explanation goes here
freeElec = setdiff(1:76,unique(occupiedElec));
C0 = nchoosek(freeElec,elecNum);
end

