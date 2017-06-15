function res = subsMulti(src, varargin)
% SUBSMULTI     Returns multiple entries from multidimensional array.
%
% res = subsMulti(src, varargin)
%
% : res = src(sub2ind(size(src), varargin{:}));
%
% See also: SUB2IND

res = src(sub2ind(size(src), varargin{:}));