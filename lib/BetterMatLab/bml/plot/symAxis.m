function symAxis(hAx, xy, varargin)
% Make the given axis symmetric around x0 and/or y0.
%
% symAxis(hAx, xy = 'x', varargin)

S = varargin2S(varargin, {
    'x0', 0
    'y0', 0
    });

if nargin < 1 || isempty(hAx)
    hAx = gca;
end
if nargin < 2, xy = 'x'; end

if any(xy == 'x')
    xLim = xlim(hAx);
    xLimMax = max(abs(xLim - S.x0));
    xlim(hAx, S.x0 + [-xLimMax, xLimMax]);
end

if any(xy == 'y')
    yLim = ylim(hAx);
    yLimMax = max(abs(yLim) - S.y0);
    ylim(hAx, S.y0 + [-yLimMax, yLimMax]);
end