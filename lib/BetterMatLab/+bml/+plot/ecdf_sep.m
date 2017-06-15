function varargout = ecdf_sep(varargin)
% ecdf_sep(x, sep, ...)
%
% OPTIONS:
% 'f_col', @cool
% 'freq', []
% 'ecdf_args', {}
% 'stairs_args', {}
% 'filt', []
[varargout{1:nargout}] = ecdf_sep(varargin{:});