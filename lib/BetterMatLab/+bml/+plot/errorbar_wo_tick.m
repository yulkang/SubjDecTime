function varargout = errorbar_wo_tick(varargin)
% [h, he] = errorbar_wo_tick(x, y, le, ue, plot_args, tick_args, ...)
% [h, he] = errorbar_wo_tick(x, y, e, [], plot_args, tick_args, ...)
[varargout{1:nargout}] = errorbar_wo_tick(varargin{:});