function [sX sY sE] = binoProp(x,y)

sX   = unique(x);
nX   = length(sX);

sY   = zeros(size(sX));
sE   = zeros(size(sX));

for iX = 1:nX
    sY(iX) = sum(y(x==sX(iX))) / nnz(x==sX(iX));
    sE(iX) = sem(y(x==sX(iX)));
end