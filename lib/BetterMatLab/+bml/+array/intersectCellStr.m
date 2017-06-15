function varargout = intersectCellStr(varargin)
% intersectCellStr  Fast intersect operation for small-sized cell arrays of strings.
%
% tf_a = intersectCellStr(a, b)
%
% tf_a is a logical array of the same size as a.
%
% Whenever possible, give smaller cell arrays to b.
%
% For large-sized (>300) cell arrays, use intersect_cellstr, which is slower for
% small-sized cell arrays.
[varargout{1:nargout}] = intersectCellStr(varargin{:});