function [pos_head, pos_tail, n_consec] = consecutive_thres(v, n, n_incl)
% [pos_head, pos_tail, n_consec] = consecutive_thres(v, n=2, n_incl=1)
%
% EXAMPLE:
% >> consecutive_thres([1 0 1 1 0 1 1 1], 2)
% ans =
%      3
% >> consecutive_thres([1 0 1 1 0 1 1 1], 3)
% ans =
%      6
% >> consecutive_thres([1 0 1 1 0 1 1 1], 1)
% ans =
%      1
     
if nargin < 2, n = 2; end
if nargin < 3, n_incl = 1; end

[~, n_consec, pos_head, pos_tail] = bml.stat.consecutive(v);

incl = n_consec >= n;
incl = find(incl, n_incl, 'first');

pos_head = pos_head(incl);
pos_tail = pos_tail(incl);
n_consec = n_consec(incl);