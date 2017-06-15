function varargout = gridplot(varargin)
% From x(R,C) and y(R,C), plot grid.
% 
% h = gridplot(hax, x, y, [plot_args ...])
%
% h(1) : vertical lines (connecting rows)
% h(2) : horizontal lines (connecting columns)
[varargout{1:nargout}] = gridplot(varargin{:});