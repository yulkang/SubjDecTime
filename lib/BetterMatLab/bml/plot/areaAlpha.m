function [hPl, hPt] = areaAlpha(x, y, plotArgs, patchArgs, varargin)
S = varargin2S(varargin, {
    'baseline', 0
    });

if nargin < 3, plotArgs = {}; end
if nargin < 4, patchArgs = {}; end

plotArgs = varargin2plot(plotArgs);
plotS    = varargin2S(plotArgs, {
    'Color', 'k'
    });

%% Patch
xPt = [S.baseline; x(:); S.baseline];
yPt = [S.baseline; y(:); S.baseline];

patchArgs = varargin2C(patchArgs, {
    'EdgeColor', 'none'
    'FaceAlpha', 0.5
    'FaceColor', plotS.Color
    });

hPt = patch('XData', xPt, 'YData', yPt, patchArgs{:});

%% Plot
hPl = plot(x, y, plotArgs{:});
