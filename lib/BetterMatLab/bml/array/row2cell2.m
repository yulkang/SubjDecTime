function v = row2cell2(v, n_in_row)
% v = row2cell2(v, n_in_row)
%
% v = nSeries x nTimepoint matrix, 
% with NaN after (and only after) the end of each row
% (like the output of cell2mat2).
%
% n_in_row(row) : if given, each must meet n_in_row(row) <= length(v{row})
%
% v = row2cell2(v)
%
% EXAMPLE:
% >> c = row2cell2([
%     1 2 3 nan nan
%     1 2 nan nan nan
%     1 2 3 4 5
%     nan nan 2 3 nan
%     nan(1,5)
%     ]); 
% celldisp(c);
% 
% c{1} =
%      1     2     3
% c{2} =
%      1     2
% c{3} =
%      1     2     3     4     5
% c{4} =
%      NaN   NaN     2     3
% c{5} =
%      []
%
% >> celldisp(row2cell2(magic(3), [2 3 0]))
% ans{1} =
%      8     1
% ans{2} =
%      3     5     7
% ans{3} =
%      []
%
% See also: cell2mat2   

if ~iscell(v)
    assert(ismatrix(v) && isnumeric(v));
    v = row2cell(v);
end
if nargin < 2
    n_in_row = cellfun(@(row) ...
        empty2v(find(~isnan(row), 1, 'last'), 0), ...
        v);
end
v = arrayfun(@(row, n_col) hVec(row{1}(1:min(n_col, end))), v, n_in_row(:), ...
    'UniformOutput', false);