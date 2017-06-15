function varargout = dir_xmat(varargin)
% Given N x K-1 matrix v of probability, return a N x K matrix where sum(v,2) = ones.
% Useful to feed Dirichlet distribution, such as dirpdf and log_dirpdf.
% 
% v = dir_xmat(v, norm_row = false)
%
% For x, give norm_row = true. For alpha, leave it false.
%
% See also: dirpdf, log_dirpdf
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = dir_xmat(varargin{:});