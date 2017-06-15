function varargout = exclude_empty(varargin)
% c = exclude_empty(c)
%
% c: cell array.
[varargout{1:nargout}] = exclude_empty(varargin{:});