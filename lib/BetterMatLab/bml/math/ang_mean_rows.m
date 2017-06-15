function [m, n, s] = ang_mean_rows(v, d)
% ang_mean_rows  Calculates angular mean of finite non-NaN numbers across DIM
%
% [m, n, s] = ang_mean_rows(v, [dim = 1])
%
% m is the angular mean in radian.
% n is the number of finite non-NaN number in each column.
% s is the sum.

if nargin < 2, d = 1; end

num = isfinite(v);
n   = sum(num,d);

vx  = cos(v);
vy  = sin(v);

vx(~num) = 0;
vy(~num) = 0;

sx   = sum(vx,d);
sy   = sum(vy,d);

mx   = sx ./ n;
my   = sy ./ n;

m    = atan2(my, mx);
