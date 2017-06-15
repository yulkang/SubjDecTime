function [xLim, yLim] = sameAxesRC(nRowSub, nColSub, ixRow, ixCol, uniteXY, toR, toC)
% SAMEAXESRC  Unite axes of subplots.
%
% [xLim yLim] = sameAxesRC(nRowSub, nColSub, ixRow, ixCol, uniteXY, toR, toC)

if nargin < 3 || isempty(ixRow), ixRow = 1:nRowSub; end
if nargin < 4 || isempty(ixCol), ixCol = 1:nColSub; end
if nargin < 5 || isempty(uniteXY), uniteXY = 'xy'; end

uniteX = any(uniteXY == 'x');
uniteY = any(uniteXY == 'y');

if exist('toR', 'var')
    subplotRC(nRowSub, nColSub, toR, toC);
    xLim = xlim;
    yLim = ylim;

else
    xLim = [inf -inf];
    yLim = [inf -inf];

    for cRow = ixRow
        for cCol = ixCol
            subplotRC(nRowSub, nColSub, cRow, cCol);

            xLim = maxRange(xLim, xlim);
            yLim = maxRange(yLim, ylim);
        end
    end
end

for cRow = ixRow
    for cCol = ixCol
        subplotRC(nRowSub, nColSub, cRow, cCol);
    
        if uniteX, xlim(xLim); end
        if uniteY, ylim(yLim); end
    end
end