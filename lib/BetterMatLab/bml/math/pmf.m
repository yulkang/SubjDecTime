function out = pmf(cdfun, v, varargin)
% out = pmf(cdfun, v, varargin)
%
% cdfun: @normcdf, etc.
% v  : a vector.
% out: diff(cdfun([v(1)-dv/2; v(:)+dv/2], varargin{:})

siz = size(v);
dv = v(2) - v(1);
v  = [v(1) - dv/2; v(:) + dv/2];

out = diff(cdfun(v, varargin{:}));
out = reshape(out, siz);