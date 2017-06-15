function loglik = glmlik(X_dat, y_dat, y_pred0, distr)
% loglik = glmlik(X_dat, y_dat, y_pred, distr)

assert(strcmp(distr, 'binomial'), 'distr=%s is not implemented yet!', distr);
loglik = bml.stat.glmlik_binomial(X_dat, y_dat, y_pred0);
