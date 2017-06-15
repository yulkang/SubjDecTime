function [R_T, res] = logit_R_T(X, ch)
% Implements Tjur (2006)'s coeff of determination for logistic regression,
% aka coeff of discrimination.
%
% [R_T, res] = logit_R_T(X, ch)
%
% See also: glmwrap, glmfit, glmval
% 
% 2015 YK wrote the initial version.

n_col0 = size(X, 2);
tf_incl = sum(~isnan(X)) > 0;

if ~any(tf_incl)
    R_T = 0;
    y_hat = zeros(size(ch)) + mean(ch(:));
    res.y_hat = y_hat;
    res.R_T = R_T;
    return;
end

X = X(:, tf_incl);

res = glmwrap(X, ch, 'binomial');
y_hat = glmval(res.b, X, 'logit');
R_T = nanmean(y_hat(ch)) - nanmean(y_hat(~ch));

res.y_hat = y_hat;
res.R_T = R_T;

if any(~tf_incl)
    res0 = res;
    
    for f = {'b', 'se', 'p'}
        res.(f{1}) = nan(n_col0 + 1, 1);
        res.(f{1})([true; tf_incl(:)]) = res0.(f{1});
    end
end
end