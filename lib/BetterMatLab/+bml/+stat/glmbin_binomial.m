function [y, X, ic, ia] = glmbin_binomial(X0, y0)
% [y, X, ic, ia] = glmbin_binomial(X0, y0)
%
% y(cond, resp) = count of trials with ic == cond and y0 == resp.
% X(cond, :) : unique rows of X0.
% ic(tr) : X(ic(tr),:) == X0(tr, :)
% ia(cond) : X(cond, :) == X0(ia(cond), :)

assert(iscolumn(y0));
assert(all((y0 == 0) | (y0 == 1) | isnan(y0)));
assert(size(X0, 1) == length(y0));

[X, ia, ic] = unique(X0, 'rows');
y0(isnan(y0)) = 2;

y = accumarray([ic, y0 + 1], 1, [max(ic), 2], @sum);
y = y(:, 1:2);