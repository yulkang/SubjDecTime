function [dst ixExcl, ixIncl] = excludeNan(src, dim)
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

if ~exist('dim', 'var')
    [~, dim] = max(size(src));
end

ixRaw       = cell(1, ndims(src));
[ixRaw{:}]  = ind2sub(size(src), find(isnan(src)));
ixExcl      = unique(ixRaw{dim});
ixIncl      = setdiff(1:size(src, dim), ixExcl);

C(1:ndims(src)) = {':'};
C{dim}      = ixIncl;
S           = substruct('()', C);
dst         = subsref(src, S);

