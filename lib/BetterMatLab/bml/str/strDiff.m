function res = strDiff(cell1)
% STRDIFF   diff() for cell vector of strings.
%
% res = strDiff(cell1)
%
% : res(k) = ~strcmp(cell1(k), cell1(k+1)) for k = 1..end-1.
%
% See also STRCMP.

res = ~strcmp(cell1(1:(end-1)), cell1(2:end));
end