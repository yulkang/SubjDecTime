function varargout = cell2vec(varargin)
% CELL2VEC - Make a vector from all numbers in a cell array of numeric arrays.
%            Useful for max(), min(), etc. 
%            Can be used when cell2mat() fails due to inconsistent sizes.
%
% v = cell2vec(c)
%
% EXAMPLE:
% >> c = {[1 2 3]', [4 5]', 6};
% >> cell2mat(c)
% Error using cat
% CAT arguments dimensions are not consistent.
% >> cell2vec(c)
% ans =
%      1     2     3     4     5     6
%
% See also: cell2mat
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = cell2vec(varargin{:});