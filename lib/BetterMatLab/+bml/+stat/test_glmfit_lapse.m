%% test_glmfit_lapse

x0 = (-6:6)';
b0 = [0.1, 1, logit(0.2)];
p0 = bml.stat.glmval_lapse(b0, x0);

plot(x0, p0);
ylim([0 1]);

%%
n = 1000;
x = repmat(x0, [n, 1]);
p = bml.stat.glmval_lapse(b0, x);
y = binornd(1, p) == 1;

[b, res] = bml.stat.glmfit_lapse(x, y);

disp([b(1:(end-1)), invLogit(b(end))]);
disp(res.se);

hold on;
bml.stat.glmplot_lapse(b, x, y);