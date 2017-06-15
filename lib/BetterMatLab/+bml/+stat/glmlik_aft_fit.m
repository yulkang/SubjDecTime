function [loglik, res] = glmlik_aft_fit(X, ch, distr)
% [loglik, res] = glmlik_aft_fit(X, ch, distr='binomial')

if nargin < 3
    distr = 'binomial';
end
assert(strcmp(distr, 'binomial'));

res = glmwrap(X, ch, 'binomial');
pred = glmval(res.b, X, 'logit');

loglik = bml.stat.glmlik_binomial(X, ch, pred);