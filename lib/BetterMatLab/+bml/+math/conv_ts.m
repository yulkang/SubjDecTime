function varargout = conv_ts(varargin)
% CONV_TS  convolve and return the first part of the result that has the same length as the 1st argument.
%
% v = conv_t(a, b, bix)
%
% a: a vector or a matrix. If an array of a higher dimension, works on the first dimension.
%    if matrix, convolution works on the first dimension.
%
% b: a vector or a matrix.
%    If matrix, and if bix is given, works like bsxfun.
%    That is,
%       v(:,k) = conv_t(a(:,k), b(:,bix(k)))
%    This works without actually replicating b, potentially saving time and memory.
%
% bix: numerical index into b's columns. Ignored if b is a vector.
%      If a is a multidimensional array, works on an index squashed from second dimension and up.
%
% Note: when convolving back in time (to find original distribution from a delayed data),
%       use conv_t_back to appropriately account for truncation of the filter
%       for the early data.
% 
% See also: conv_t_back
[varargout{1:nargout}] = conv_ts(varargin{:});