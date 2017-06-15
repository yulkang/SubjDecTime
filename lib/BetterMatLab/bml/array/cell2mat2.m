function m = cell2mat2(c, pad_with, enforce_double)
% CELL2MAT2  cell2mat with padding. Return original if non-cell. Enforces each element to be a horizontal vector.
%
% m = cell2mat2(c, [pad_with=NaN])
%
% EXAMPLE:
% >> cell2mat2({[1 2 3], [ 1 3], 1, [], [ 1 2 3 4]})
% ans =
%      1     2     3   NaN
%      1     3   NaN   NaN
%      1   NaN   NaN   NaN
%    NaN   NaN   NaN   NaN
%      1     2     3     4

if ~iscell(c), m = c; return; end
if nargin < 2, pad_with = nan; end
if nargin < 3, enforce_double = true; end

n = length(c);
l = cellfun(@length, c);
max_l = max(l);

is_nested_cell = cellfun(@iscell, c);
while any(is_nested_cell)
    c(is_nested_cell) = cellfun(@(cc) cc{1}, c(is_nested_cell), ...
        'UniformOutput', false);
    is_nested_cell = cellfun(@iscell, c);
end

if enforce_double
    c2 = cellfun(@(cc) [double(cc(:)'), zeros(1, max_l - length(cc)) + pad_with], c, ...
        'UniformOutput', false);
else
    c2 = cellfun(@(cc) [cc(:)', zeros(1, max_l - length(cc)) + pad_with], c, ...
        'UniformOutput', false);
end
m  = cell2mat(c2(:));