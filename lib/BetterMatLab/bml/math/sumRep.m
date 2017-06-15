function m = sumRep(m, d)
% SUMREP sum across given dimension and repmat to recover original size.
%
% Useful for plotting purposes only. For other operations, use BSXFUN.
%
% m = sumRep(m, d);
%
% See also: bsxfun.
%
% 2013 (c) Yul Kang.

s(1:ndims(m)) = 1;
s(d)          = size(m,d);

m = repmat(sum(m,d),s);