function ab = betaprod_const(ab, c)
% Parameters of the product of a beta-distributed random variable and a constant.
%
% 2016 implemented by Yul Kang. hk2699 at columbia dot edu.

a = ab(:,1);
b = ab(:,2);

mu0 = a ./ (a + b);
vr0 = a .* b ./ ((a + b) .^ 2 .* (a + b + 1));

mu = mu0 .* c;
vr = vr0 .* c .^ 2;

ab(:,1) = mu.^2 .* (1 - mu) ./ vr - mu;
ab(:,2) = ab(:,1) .* (1 - mu) ./ mu;

return;

%% Test
ab0 = [1 4];
c = 0.5;
ab = bml.stat.betaprod_const(ab0, c);

mu0 = bml.stat.betamean(ab0);
mu = bml.stat.betamean(ab);

vr0 = bml.stat.betavar(ab0);
vr = bml.stat.betavar(ab);

disp([ab, ab0]);
disp([mu, mu0, mu ./ mu0]);
disp([vr, vr0, vr ./ vr0]);