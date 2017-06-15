function [xLim, yLim] = sameAxes(nRowSub, nColSub, ixPlot, uniteXY, toWhich)
% SAMEAXES  Unite axes of subplots.
%
% [xLim yLim] = sameAxes(nRowSub, nColSub, ixPlot=(all), uniteXY='xy', toWhich=(max));
% [xLim yLim] = sameAxes(h_axes,  [], ...)
% [xLim yLim] = sameAxes(..., toWhich = {xLim, yLim})
%
% uniteXY : 'x', 'y', 'xy', or 'off'
% ixPlot  : omit to unite all subplots' axes.
% toWhich : omit to set to maximum of all subplots' axes.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

%% nRowSub, nColSub -> h_axes
if ~exist('nColSub', 'var') || isempty(nColSub)
    h_axes = nRowSub(:);
else
    i_h = 0;
    h_axes = zeros(1, nRowSub * nColSub);
    for ii = 1:nRowSub
        for jj = 1:nColSub
            i_h = i_h + 1;
            h_axes(i_h) = subplotRC(nRowSub, nColSub, ii, jj);
        end
    end
end

%% ixPlot
if ~exist('ixPlot', 'var') || isempty(ixPlot)
    ixPlot = 1:numel(h_axes);
end

%% uniteXY -> uniteX, uniteY
if ~exist('uniteXY', 'var') || isempty(uniteXY), uniteXY = 'xy'; end

uniteX = any(uniteXY == 'x');
uniteY = any(uniteXY == 'y');

%% toWhich -> xLim
if ~exist('toWhich', 'var') || isempty(toWhich)
    xLim_max = [inf, -inf];
    yLim_max = [inf, -inf];
    
    for ii = ixPlot
        xLim = get(h_axes(ii), 'XLim'); % xlim(h_axes(ii));
        yLim = get(h_axes(ii), 'YLim'); % ylim(h_axes(ii));
        
        xLim_max = [min(xLim_max(1), xLim(1)), max(xLim_max(2), xLim(2))];
        yLim_max = [min(yLim_max(1), yLim(1)), max(yLim_max(2), yLim(2))];
    end
    
    xLim = xLim_max;
    yLim = yLim_max;
    
elseif iscell(toWhich)
    xLim = toWhich{1};
    yLim = toWhich{2};
else
    xLim = xlim(h_axes(toWhich));
    yLim = ylim(h_axes(toWhich));
end

%% Set xlim and ylim
for ii = ixPlot
    if uniteX, xlim(h_axes(ii), xLim); end
    if uniteY, ylim(h_axes(ii), yLim); end
end
