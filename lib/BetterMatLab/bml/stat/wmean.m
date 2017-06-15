function m = wmean(v, w, varargin)
% Weighted mean. W is expanded to match v's dimension, and vice versa.
%
% m = wmean(v, w, varargin)
%
% See also: reshape2vec, nanwmean
%
% 2015 (c) Yul Kang. yul.kang.on at gmail dot com.

sum_w = sum(w, varargin{:});
sum_v = sum(bsxfun(@times, v, w), varargin{:});
m     = bsxfun(@rdivide, sum_v, sum_w);