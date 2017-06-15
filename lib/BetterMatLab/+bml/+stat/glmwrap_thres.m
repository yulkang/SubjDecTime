function S = glmwrap_thres(X, y, distr, varargin)
% S = glmwrap_thres(X, y, distr, varargin)

assert(strcmp(distr, 'binomial'));

S = bml.stat.glmwrap(X, y, distr, varargin{:});

[thres, spe, bnd_thres, bnd_spe] = ...
    bml.stat.logit2thres(S.b, [], S.stats.covb);

S = copyFields(S, packStruct(thres, spe, bnd_thres, bnd_spe));
end