function y = mdl_pred(mdl, varargin)
% y = mdl_pred(mdl, ...)
%
% NOTE: choosing a subset of trials or vars in this function does not
% refit the model. Use mdl_addTerms or mdl_removeTerms or similar functions
% to refit.
%
% y = X(:,vars) * coef;
%
% OPTIONS:
% 'vars', {} % cell array of variable names
% 'to_excl_vars', true % exclude VARS if true
% 'tr_incl', ':'
%
% See also
% : bml.stat.mdl_addTerms, bml.stat.mdl_removeTerms
%   addTerms, removeTerms, fitglm

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'vars', {} % cell array of variable names
    'to_excl_vars', true % exclude VARS if true
    'tr_incl', ':'
    });

if S.to_excl_vars
    S.vars = setdiff(mdl.PredictorNames, S.vars, 'stable');
end
var_incl = ismember(mdl.VariableNames, S.vars) & mdl.VariableInfo.InModel;
X = table2array(mdl.Variables);

% Choose a part of X with tr_incl and var_incl
X = X(S.tr_incl, var_incl);

incl_wi_inModel = strcmpfinds(S.vars, mdl.PredictorNames);
incl_wi_inModel = incl_wi_inModel(~isnan(incl_wi_inModel));

n_tr = size(X, 1);
X = [ones(n_tr, 1), X];

coef = mdl.Coefficients.Estimate([1; (incl_wi_inModel(:) + 1)]);
y = X * coef;
end