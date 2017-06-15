function loglik = glmlik_binomial(X_dat, y_dat, y_pred0)
% loglik = glmlik_binomial(X_dat, y_dat, y_pred)

if isvector(y_dat)
    assert(iscolumn(y_dat));
    assert(iscolumn(y_pred0));
    assert(size(X_dat, 1) == size(y_dat, 1));
    assert(length(y_dat) == length(y_pred0));

    [y_binned, ~, ~, ia] = bml.stat.glmbin_binomial(X_dat, y_dat);
    y_pred = y_pred0(ia);
else
    ch2 = y_dat(:,1);
    ch1 = y_dat(:,2) - ch2;
    y_binned = [ch1, ch2];
    
    y_pred = y_pred0;
end

y_pred = [1 - y_pred, y_pred];

n_cond = size(y_binned, 1);
loglik = 0;
for cond = 1:n_cond
    loglik = loglik - bml.stat.nll_bin(y_pred(cond, :), y_binned(cond, :));
end

% plot(y_binned(:,2) ./ sum(y_binned,2), 'o'); hold on;
% plot(y_pred(:,2) ./ sum(y_pred,2), '-'); hold off;
% disp(loglik);