function res = unionCellStr(cell1, cell2)
% Union of cell vectors of strings preserving the order and excluding duplicates.
% cell1's entries come before cell2's.
%
% Example>
% unionCellStr({'b', 'c'}, {'a', 'b'}))
% ans = 
%   'b'  'c'  'a'

res = union(cell1, cell2, 'stable'); % [cell1, cell2(~strcmps(cell1, cell2))];
