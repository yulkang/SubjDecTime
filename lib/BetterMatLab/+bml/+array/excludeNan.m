function varargout = excludeNan(varargin)
% EXCLUDENAN    Excludes slice containing NaN, along the specified dimension.
%
% [dst, ixExcl, ixIncl]  = excludeNan(src, dim)
%
% src       : An array.
% dim       : Dimension to slice. If unspecified, take longest dimension.
% dst       : src, excluding the slices containing NaN.
% ixExcl    : Index of excluded slices.
% ixIncl    : Index of included slices.
%
% See also ISNAN.
[varargout{1:nargout}] = excludeNan(varargin{:});