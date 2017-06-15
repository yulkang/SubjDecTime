function [coeff, score, latent, tsquared, reduced, n_comp, var_exp] = princomp_reduce(X, varargin)
% [coeff, score, latent, tsquared, reduced, n_comp] = princomp_reduce(X, ...)
%
% 'thres_by', 'prop_var'
% 'thres',    .99

S = varargin2S(varargin, {
    'thres_by', 'prop_var'
    'thres',    .99
    });

[coeff, score, latent, tsquared] = princomp(X);

switch S.thres_by
    case 'prop_var'
        n_comp = find(cumsum(latent) / sum(latent) > S.thres, 1, 'first');
    case 'n_comp'
        n_comp = S.thres;
end

if nargout >= 5, 
    reduced = score(:,1:n_comp) * coeff(:,1:n_comp)';
end

var_exp = sum(latent(1:n_comp)) / sum(latent);