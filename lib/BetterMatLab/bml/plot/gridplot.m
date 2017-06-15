function h = gridplot(hax, x, y, arg1, arg2)
% From x(R,C) and y(R,C), plot grid.
% 
% h = gridplot(hax, x, y, [plot_args ...])
%
% h(1) : vertical lines (connecting rows)
% h(2) : horizontal lines (connecting columns)

if nargin < 4, arg1 = {}; end
if nargin < 5, arg2 = {}; end

plot(hax, x,  y,  arg1{:}); 
set(hax, 'NextPlot', 'add');
plot(hax, x', y', arg2{:}); 
set(hax, 'NextPlot', 'replace');
