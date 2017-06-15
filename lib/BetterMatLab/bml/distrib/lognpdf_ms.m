function p = lognpdf_ms(x, m, s)
% p = lognpdf_ms(x, m, s)
%
% m, s: mean and std

mu = log(m) - log((s ./ m) .^ 2 + 1) ./ 2;
sig = sqrt(log((s ./ m) .^ 2 + 1));
p = lognpdf(x, mu, sig);

% %%
% syms mu sig s m real
% % m = exp(mu + sig ^2 / 2);
% % s = sqrt(exp(sig^2 - 1) .* exp(2 .* mu + sig^2));
% [m1, s1] = solve(exp(mu + sig ^2 / 2) == m, sqrt(exp(sig^2 - 1) .* exp(2 .* mu + sig^2)) == s, mu, sig)