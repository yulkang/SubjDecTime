function [yMean ySEM xSort nInMean ySort] = runningMean(xDat, yDat, xRange, nThres, varargin)
% Mean within the given x range.
% 
% [yMean ySEM xSort nInMean] = runningMean(xDat, yDat, xRange, nThres, ...)
%
% xRange: [xRangeLeft xRangeRight]
%
% OPTIONS
% -------
% 'w', []
%
% See also: vec4runningMean

if nargin < 4 || isempty(nThres), nThres = 0; end

siz = size(yDat);

S = varargin2S(varargin, {
    'w', []
    });

[xSort ixSort] = sort(xDat);
ySort = yDat(ixSort);

N       = length(xDat);
if isempty(S.w)
    w = ones(1, N);
else
    w = S.w;
end
wCumsum = cumsum(w);

ySort  = ySort(:) .* w(:);
ySort2 = ySort.^2;
yCumsum = cumsum(ySort);
yCumsum2 = cumsum(ySort2);

cHead   = 1;
cTail   = 1;

yMean   = zeros(size(yDat));
ySEM    = zeros(size(yDat));

nInMean = zeros(1,N);

for cLoc = 1:N
    cHead   = cHead - 1 + find(xSort(cHead:end) <= xSort(cLoc)+xRange(2), ...
                               1, 'last');
    cTail   = cTail - 1 + find(xSort(cTail:cLoc) >= xSort(cLoc)+xRange(1), ...
                               1, 'first');

    cSum          = yCumsum(cHead) - yCumsum(cTail) + ySort(cTail);
    cN            = wCumsum(cHead) - wCumsum(cTail) + w(cTail); % cHead - cTail + 1;
    yMean(cLoc)   = cSum / cN;

    cVar    = ((yCumsum2(cHead) - yCumsum2(cTail) + ySort2(cTail)))/(cN-1)...
            - yMean(cLoc)^2 * cN/(cN-1);
    ySEM(cLoc) = sqrt(cVar / cN);

    nInMean(cLoc) = cN;
end

if nThres > 0
    filt    = nInMean >= nThres;
    yMean   = yMean(filt);
    ySEM    = ySEM(filt);
    xSort   = xSort(filt);
    ySort   = ySort(filt);
end

if ~isequal(size(yMean), siz)
    yMean = reshape(yMean, siz);
    ySEM  = reshape(ySEM,  siz);
end
end
