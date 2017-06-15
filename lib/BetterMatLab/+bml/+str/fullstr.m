function varargout = fullstr(varargin)
% FULLSTR : Connects strings with sep. Unlike str_bridge, puts '_' even when empty.
%
% EXAMPLE:
% >> fullstr('_', 'a', 'b', '', 'c')
% ans =
% a_b__c
%
% See also: strsep, funPrintf, str_bridge
[varargout{1:nargout}] = fullstr(varargin{:});