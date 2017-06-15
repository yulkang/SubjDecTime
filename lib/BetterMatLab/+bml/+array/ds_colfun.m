function varargout = ds_colfun(varargin)
% Apply a function to each column of a dataset.
%
% ds = ds_colfun(ds, fun, [col={'col1', ...}])
[varargout{1:nargout}] = ds_colfun(varargin{:});