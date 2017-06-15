function tf = within_intervals(num, st, en)
% tf(k) returns if the given scalar num is in [st(k), en(k)].
%
% tf = within_intervals(num, st, en)
%
% Example:
% >> within_intervals(2, [1 5], [2 6])
% ans =
%      1     0      % 2 is in [1 2], but not in [5 6].
% 
% >> within_intervals(5, [1 5], [2 6])
% ans =
%      0     1      % 5 is in [5 6].
% 
% >> within_intervals(4, [1 5], [2 6])
% ans =
%      0     0      % 4 is in neither.

tf = (num >= st) & (num <= en);