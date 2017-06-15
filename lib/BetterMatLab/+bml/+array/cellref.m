function varargout = cellref(varargin)
% v = cellref(C, ix)
%
% Reference vectors in each cell, and return NaN for places out of range.
%
% EXAMPLE:
% >> C = {1:3; 1:5; 1};
% >> cellref(C, 2)
% ans =
%      2
%      2
%    NaN
% 
% >> cellref(C, 1:5)
% ans =
%      1     2     3   NaN   NaN
%      1     2     3     4     5
%      1   NaN   NaN   NaN   NaN
[varargout{1:nargout}] = cellref(varargin{:});