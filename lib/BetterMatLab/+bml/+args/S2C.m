function varargout = S2C(varargin)
% Makes structure or object into a cell vector of variable names and values.
% If s is non-scalar, c is a cell array of the same size of cell vectors.
%
% c = S2C(s, [f])
% f: Fields to include.
%    {'field1', 'field2', ...} % If omitted, convert all.
[varargout{1:nargout}] = S2C(varargin{:});