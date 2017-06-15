function glmplot_lapse(b, X, y, varargin)
S = varargin2S(varargin, {
    'n_bin', 9
    });

[bin, ~, x_plot] = quantilize(X, S.n_bin);
yhat = bml.stat.glmval_lapse(b, x_plot);
ydat = accumarray(bin, y, [S.n_bin, 1], @mean);

plot(x_plot, yhat, 'k-');
hold on;
plot(x_plot, ydat, 'ko');
