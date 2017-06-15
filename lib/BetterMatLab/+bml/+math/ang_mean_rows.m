function varargout = ang_mean_rows(varargin)
% ang_mean_rows  Calculates angular mean of finite non-NaN numbers across DIM
%
% [m, n, s] = ang_mean_rows(v, [dim = 1])
%
% m is the angular mean in radian.
% n is the number of finite non-NaN number in each column.
% s is the sum.
[varargout{1:nargout}] = ang_mean_rows(varargin{:});