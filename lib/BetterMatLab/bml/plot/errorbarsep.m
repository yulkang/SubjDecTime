function [h, he] = errorbarsep(x, y, l, u, colors, plotArgs, tickArgs)
% [h, he] = errorbarsep(x, y, e, [], colors, plotArgs, tickArgs)
% [h, he] = errorbarsep(x, y, l, u, colors, plotArgs, tickArgs)

if nargin < 6, plotArgs = {}; end
if nargin < 7, tickArgs = {}; end

x = enforceCell(x);
y = enforceCell(y);
l = enforceCell(l);
u = enforceCell(u);
n = max(size(x,2), size(y,2));
x = rep2fit(x, [1, n]);
y = rep2fit(y, [1, n]);
l = rep2fit(l, [1, n]);
if isempty(u)
    u = l;
    l = -u;
else
    u = rep2fit(u, [1, n]);
end

if isa(colors, 'function_handle'), colors = colors(n); end

tickArgs = varargin2C(tickArgs);

for ii = n:-1:1
    cPlotArgs = varargin2C({
        'Color', colors(ii,:)
        }, plotArgs);
    
    [h{ii}, he{ii}] = errorbar_wo_tick(x{ii}, y{ii}, l{ii}, u{ii}, ...
        cPlotArgs, tickArgs);
    
    hold on;
end
hold off;
end

function v = enforceCell(v)
if ~iscell(v)
    if isrow(v) && numel(v) > 1, v = v'; end 
    v = col2cell(v);
end
end