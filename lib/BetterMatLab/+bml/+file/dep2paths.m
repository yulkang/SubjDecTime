function varargout = dep2paths(varargin)
% [paths, files] = dep2paths(function_name, ...)
%
% Wrapper for DEP2TXT that returns unique paths that the given function depends on.
%
% See also: DEP2TXT
[varargout{1:nargout}] = dep2paths(varargin{:});