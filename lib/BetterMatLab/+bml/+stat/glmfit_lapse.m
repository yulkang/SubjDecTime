function [b, res] = glmfit_lapse(X0, y0, varargin)
% b(1) : offset
% b(1 + (1:size(X0,2))): beta
% b(end) : logit(p_lapse)
%
% y0 : logical column vector

% 2016 Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'lapse0', logit(1e-3)
    'lapse_min', logit(1e-5)
    'lapse_max', logit(0.2)
    'bias0', 0
    'bias_min', -1
    'bias_max', 1
    'slope0', 5
    'slope_min', -5
    'slope_max', 50
    'opt', {}
    });

n_tr = size(X0, 1);
n_col = size(X0, 2);
assert(iscolumn(y0) && length(y0) == n_tr);

b0 = [S.bias0, zeros(1, n_col) + S.slope0, logit(S.lapse0)];
lb = [S.bias_min, zeros(1, n_col) + S.slope_min, S.lapse_min];
ub = [S.bias_max, zeros(1, n_col) + S.slope_max, S.lapse_max];

opt = optimoptions('fmincon', S.opt{:});

[b, fval, exitflag, output, lambda, grad, hessian] = ...
    fmincon(@(b) -bml.stat.glmlik_lapse(b, X0, y0), ...
        b0, [], [], [], [], lb, ub, [], opt);

se = sqrt(diag(inv(hessian)));
res = packStruct(b, se, fval, exitflag, output, lambda, grad, hessian);
