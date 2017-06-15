function [h, f, x, flo, fup] = ecdf_wrap(y, ecdf_args, stairs_args)
% [h, f, x, flo, fup] = ecdf_wrap(y, ecdf_args, stairs_args)

if nargin < 2, ecdf_args = {}; end
if nargin < 3, stairs_args = {}; end

[f, x, flo, fup] = ecdf(y, ecdf_args{:});
h = stairs(x, f, stairs_args{:});