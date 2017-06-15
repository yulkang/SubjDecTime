function plot_logistic(b, x, dat, fit_plot_opt, dat_plot_opt)
% plot_logistic(b, x, dat, fit_plot_opt, dat_plot_opt)
%
% b: two beta weights (bias and slope) returned by glmfit
% dat: [x_dat(:) resp(:)]

% Plot fit
y = glmval(b, x, 'logit');

plot(x, y, fit_plot_opt{:}); hold on;

% Plot data
[m, ~, x_dat] = mean_binned(dat(:,1), dat(:,2));

plot(x_dat, m, dat_plot_opt{:}); hold off;