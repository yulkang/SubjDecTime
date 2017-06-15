function hTip = dataTip(x, y, varargin)
% dataTip(x, y, varargin)
%
% Options:
% 'v', [] % vector or cell array. Defaults to y.
% 'dx', 0
% 'dy', 0.05
% 'dxUnit', 'normalized'
% 'dyUnit', 'normalized'
% 'fmt', '%1.2f'
% 'textOpt', {}
%
% Text options:
% 'HorizontalAlignment', 'center'
% 'VerticalAlignment',   'top'
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

if ishandle(x)
    hLine  = x;
    if nargin >= 2, ix = y; else ix = []; end
    
    x = get(hLine, 'XData');
    y = get(hLine, 'YData');
    
    if ~isempty(ix), x = x(ix); y = y(ix); end
    
    hAx = get(hLine, 'Parent');
else
    hAx = gca;
end

xLim = xlim;
yLim = ylim;

S = varargin2S(varargin, {
    'v', [] % vector or cell array. Defaults to y.
    'dx', 0
    'dy', 0.05
    'dxUnit', 'normalized'
    'dyUnit', 'normalized'
    'fmt', '%1.2f'
    'textOpt', {}
    });

S.textOpt = varargin2C(S.textOpt, {
    'HorizontalAlignment', 'center'
    'VerticalAlignment',   'top'
    });

if isempty(S.v)
    S.v = y;
end

if strcmp(S.dxUnit, 'normalized')
    dx = S.dx * diff(xLim);
else
    dx = S.dx;
end
if strcmp(S.dyUnit, 'normalized')
    dy = S.dy * diff(yLim);
else
    dy = S.dy;
end

xPlot = x + dx;
yPlot = y + dy;

n = length(x);

for ii = n:-1:1
    if iscell(S.v)
        txt = S.v{ii};
    else
        txt = sprintf(S.fmt, S.v(ii));
    end
    
    hTip(ii) = text(xPlot(ii), yPlot(ii), txt, S.textOpt{:});
end