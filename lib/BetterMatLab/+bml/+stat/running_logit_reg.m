function [thres, spe, res] = running_logit_reg(X0, y0, win, wt)
% [thres, spe, res] = running_logit_reg(X0, y0, win, wt)

n = size(X0, 1);
spe = nan(n, 1);
thres = nan(n, 1);

if ~exist('wt', 'var')
    wt = ones(n, 1);
end

for tr = n:-1:1
    st = max(tr - win(1), 1);
    en = min(tr + win(2), n);
    
    X = X0(st:en, :);
    y = y0(st:en, :);
    
    res0 = glmwrap(X, y, 'binomial', 'weights', wt);
    [thres(tr, 1), spe(tr, 1)] = bml.stat.logit2thres(res0.b);
    
    res(tr, 1) = res0;
end
end