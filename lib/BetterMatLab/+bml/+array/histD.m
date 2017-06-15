function varargout = histD(varargin)
% histD Counts occurence of unique values, and plot histogram.
% 
% [c, x, h, y] = histD(d, ['opt1', opt1, ...])
%
% d     Data.
% c     Count.
% x     Unique values.
% h     Handle of the plot.
% y     Category index, such that all(x(y) == d) == true.
%
% Options:
%
% 'x'        : Unique values to look for. Defaults to unique(d).
% 'w'        : Weight to each data point.
% 'to_plot'  : Defaults to true.
% 'normalize', false
% 'to_print',  false
% 'h',        []
% 'remove_empty', true
%
% 2013 (c) Yul Kang.
[varargout{1:nargout}] = histD(varargin{:});