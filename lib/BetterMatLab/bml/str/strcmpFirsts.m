function res = strcmpFirsts(a, b, varargin)
% strcmpFirst for a cell array A. Returns a matrix (A x B).
% res = strcmpFirsts(a, b, varargin)
%
% EXAMPLES:
% strcmpFirsts({'a', 'ab'}, {'a', 'ab', 'abc', 'bab'})
% ans =
%      1     1     1     0
%      1     1     1     0
%      
% strcmpFirsts({'a', 'ab'}, {'a', 'ab', 'abc', 'bab'}, 'strict', true)
% ans =
%      1     1     1     0
%      0     1     1     0
%
% See also: strcmpFirst
%
% 2015 (c) Yul Kang. yul dot kang dot on at gmail.
assert(iscell(a) && iscell(b));
na = numel(a);
nb = numel(b);
res = false(na, nb);

for ia = 1:numel(a)
    c_res = strcmpFirst(a{ia}, b, varargin{:});
    res(ia, :) = c_res(:)';
end