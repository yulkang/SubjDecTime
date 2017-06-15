function varargout = filt_multi(varargin)
% [A,B,..] = filt_multi(ix_or_fun, A,B,...);
%
% filt
% : ix or function handle.
%   If function handle, filt = filt(varargin{1}).
%
% A = A(ix);
% B = B(ix);
% ...
[varargout{1:nargout}] = filt_multi(varargin{:});