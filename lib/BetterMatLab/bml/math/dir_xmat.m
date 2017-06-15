function v = dir_xmat(v, norm_row, varargin)
% Given N x K-1 matrix v of probability, return a N x K matrix where sum(v,2) = ones.
% Useful to feed Dirichlet distribution, such as dirpdf and log_dirpdf.
% 
% v = dir_xmat(v, norm_row = false)
%
% For x, give norm_row = true. For alpha, leave it false.
%
% See also: dirpdf, log_dirpdf
%
% 2014-2016 (c) Yul Kang. hk2699 at columbia dot edu.

v = v + eps; % Prevent NaN

tot = sum(v(:));
v   = v ./ tot;
v(:,end+1) = max(1 - sum(cumsum(v),2), 0);

if nargin >= 2 && norm_row
    v = bsxfun(@rdivide, v, sum(v, 2));
end