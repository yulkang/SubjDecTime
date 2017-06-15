function varargout = dirSub(varargin)
% c = dirSub(d, excl, add_d, varargin)
% 
% Recursively finds all subdirectories of d, excluding those starts with '.'.
%
% See also: dirCell, dir
[varargout{1:nargout}] = dirSub(varargin{:});