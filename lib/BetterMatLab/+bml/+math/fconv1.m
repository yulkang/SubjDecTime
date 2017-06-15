function varargout = fconv1(varargin)
% FCONV1 Vectorized fast convolution on the first dimension
%
% y = FCONV1(x, h) convolves x and h, column by column
%
% x: input array
% h: input array
% 
% See also: CONV, FCONV
[varargout{1:nargout}] = fconv1(varargin{:});