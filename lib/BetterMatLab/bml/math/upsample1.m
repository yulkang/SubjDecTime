function x = upsample1(x, fac)
% UPSAMPLE1  Linear upsampling
%
% x = upsample1(x, fac)

n = length(x);

x = interp1(fac:fac:(fac*n), x, fac:(fac*n));