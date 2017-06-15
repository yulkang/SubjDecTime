function [m, s] = gamfit_ms(freq)
% [m, s] = gamfit_ms(freq)

% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

n = length(freq);
x = 1:n;
if iscolumn(freq)
    x = x';
end

[s0, m0] = std_distrib(freq);
ms0 = [m0, s0];

f_cost = @(ms) nll_bin(gampdf_ms(x, ms(1), ms(2)), freq + eps);

ms = fminsearchbnd(f_cost, ms0, [eps, eps], m0*2, s0*2);

m = ms(1);
s = ms(2);
end