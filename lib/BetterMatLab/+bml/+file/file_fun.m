function varargout = file_fun(varargin)
% FILE_FUN - runs a function on files
%
% res = file_fun(fun, files, varargin)
%
% vars      : variable names in a cell array
[varargout{1:nargout}] = file_fun(varargin{:});