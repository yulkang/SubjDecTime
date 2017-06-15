function varargout = cell_subsref(varargin)
% M = cell_subsref(C, {subs1, ...}, [uniform_output = true, @(err,varargin) nan])
[varargout{1:nargout}] = cell_subsref(varargin{:});