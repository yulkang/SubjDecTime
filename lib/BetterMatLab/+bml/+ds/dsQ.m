function varargout = dsQ(varargin)
% ds = dsQ(ds, op, q, v)
%
% op: 'tf', 'ix', 'set', 'set1', 'get', 'get1'
% q:  Name-value pairs
% v:  column indices (get) or name-value pairs (set).
[varargout{1:nargout}] = dsQ(varargin{:});