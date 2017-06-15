function varargout = fconv(varargin)
%FCONV Fast Convolution
%   [y] = FCONV(x, h) convolves x and h
%
%      x = input vector
%      h = input vector
% 
%      See also CONV
%
%   NOTES:
%
%   1) I have a short article explaining what a convolution is.  It
%      is available at http://stevem.us/fconv.html.
%
%
%Version 1.0
%Coded by: Stephen G. McGovern, 2003-2004.
%
% YK (2013): Added buffering to make it faster
[varargout{1:nargout}] = fconv(varargin{:});