function llk = glmlik_lapse(b, X0, y0)
% b(1) : offset
% b(1 + (1:size(X0,2))): beta
% b(end) : logit(p_lapse)
%
% y0 : logical column vector
%
% llk : log likelihood + constant
%
% Note: llk is the log likelihood + constant, 
% because it ignores permutations among conditions.

% 2016 Yul Kang. hk2699 at columbia dot edu.

assert(iscolumn(y0));
assert(islogical(y0));

p_pred = bml.stat.glmval_lapse(b, X0);

llk = nansum(log(p_pred(y0) + eps)) ...
    + nansum(log(1 - p_pred(~y0) + eps));        

% log_pred = log(min(max([1 - p_pred, p_pred], eps), 1 - eps));
% 
% llk = sum(log_pred(~y0, 1)) + sum(log_pred(y0, 2));