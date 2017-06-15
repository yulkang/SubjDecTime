function [se, n] = sem_rows(v, d)
% sem_rows  Standard error of mean of finite non-NaN numbers across DIM.
%
% [se, n] = sem_rows(v, dim)
%
% n is the number of finite non-NaN numbers in each column.
%
% See also sem, mean_rows, std_rows

if ~exist('d', 'var'), d = 1; end

[st, n] = std_rows(v, d);
se = st ./ sqrt(n);
