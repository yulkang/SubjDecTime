function varargout = hist_row(varargin)
% HIST_ROW  Similar to histD but works on rows.
%
% [cnt, reper, i_reper] = hist_row(M, varargin)
%
% EXAMPLE:
% >> [cnt, reper, i_reper] = hist_row([1 3; 1 3; 1 2; 1 3; 1 3])
% cnt =
%      1     4
% reper =
%      1     2
%      1     3
% i_reper =
%      2
%      2
%      1
%      2
%      2
% 
% >> [cnt, reper, i_reper] = hist_row([1 3; 1 3; 1 2; 1 3; 1 3], 'order', 'stable')
% cnt =
%      4     1
% reper =
%      1     3
%      1     2
% i_reper =
%      1
%      1
%      2
%      1
%      1
%
% See also: histD
[varargout{1:nargout}] = hist_row(varargin{:});