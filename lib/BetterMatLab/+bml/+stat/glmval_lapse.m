function yhat = glmval_lapse(b, X0)
% glmval for the logistic model with a lapse term.
% b(1) : offset
% b(1 + (1:size(X0,2))): beta
% b(end) : logit(p_lapse)
%
% yhat : probability

% 2016 Yul Kang. hk2699 at columbia dot edu.

bias = b(1);
% offset = b(1);
beta = b(2:(end-1));
lapse = invLogit(b(end));

y0 = invLogit((X0 - bias) * beta);
% y0 = invLogit(X0 * beta(:) + offset);
yhat = y0 * (1 - lapse) + 0.5 * lapse;

