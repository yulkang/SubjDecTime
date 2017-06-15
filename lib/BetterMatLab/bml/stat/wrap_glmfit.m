function S = wrap_glmfit(varargin)
% S = wrap_glmfit(varargin)
%
% S has fields of b, dev, stats, p, and se.

[b, dev, stats] = glmfit(varargin{:});
p = stats.p;
se = stats.se;

S = packStruct(b, dev, stats, p, se);