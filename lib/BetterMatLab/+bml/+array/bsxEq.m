function varargout = bsxEq(varargin)
% tf = bsxEq(a, b)
%
% tf : logical column vector of length(a) of whether each element of a
%      equals any of b.
[varargout{1:nargout}] = bsxEq(varargin{:});