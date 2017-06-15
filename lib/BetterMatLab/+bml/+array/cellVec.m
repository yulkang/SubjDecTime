function varargout = cellVec(varargin)
% CELLVEC   Get scalar numeric/cell/vector numeric and returns a cell vector.
%           Repeats elements to fit the desired length if necessary.
%
% varargout = cellVec(len, varargin)
[varargout{1:nargout}] = cellVec(varargin{:});