function [m, n, s] = mean_rows(v, d)
% mean_rows  Calculates mean of finite non-NaN numbers across DIM
%
% [m, n, s] = mean_rows(v, [dim = 1])
%
% n is the number of finite non-NaN number in each column.
% s is the sum.

if nargin < 2, d = 1; end

num = isfinite(v);
n   = sum(num,d);

v(~num) = 0;

s   = sum(v,d);
m   = s ./ n;
