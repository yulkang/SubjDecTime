function varargout = empty2nanCell(varargin)
% EMPTY2NANCELL     Replaces empty cell with {nan}.
%
% dst = empty2nanCell(src)
%
% src: cell array.
% dst: cell array of same size.
[varargout{1:nargout}] = empty2nanCell(varargin{:});