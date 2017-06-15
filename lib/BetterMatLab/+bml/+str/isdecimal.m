function varargout = isdecimal(varargin)
% Tests if a string is a decimal contant as in C (rather than octal or hexadecimal).
%
% tf = isdecimal(s)
[varargout{1:nargout}] = isdecimal(varargin{:});