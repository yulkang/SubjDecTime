function [st, n] = std_rows(v, d)
% std_rows  Standard deviation of finite non-NaN numbers across DIM.
%
% [st, n] = sem_rows(v, dim)
%
% n is the number of finite non-NaN numbers in each column.
%
% See also std, mean_rows, sem_rows

if ~exist('d', 'var'), d = 1; end

num = isfinite(v);
n   = sum(num, d);
n1  = max(n-1, 1);

v(~num) = 0;

st = sqrt((sum(v.^2, d)./n - (sum(v, d)./n).^2) .* (n./n1));
