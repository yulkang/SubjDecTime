function ab = betaprod(ab0)
% Parameters of the product of two beta-distributed random variables
%
% ab0 : [a1, b1, a2, b2] on each row
%    or [a1, b1, p2, nan] or [p1, nan, a1, b2] to multiply with a constant.
% ab  : [a, b] on each row
%
% after Dunkl 2013.
%
% 2016 implemented by Yul Kang. hk2699 at columbia dot edu.

a0 = ab0(:, [1 3]);
b0 = ab0(:, [2 4]);

incl_p = sum(isnan(b0), 2) == 1;

if any(incl_p)
    ab_ix = find(~isnan(b0(incl_p, :)));
    p_ix = find(isnan(b0(incl_p, :)));
    
    a0_incl = a0(incl_p, :);
    a0_incl = a0_incl(ab_ix);
    b0_incl = b0(incl_p, :);
    b0_incl = b0_incl(ab_ix);
    
    p0 = nansum(a0(p_ix), 2);
    
    ab(incl_p, :) = bml.stat.betaprod_const([a0_incl, b0_incl], p0);
    ab(~incl_p, :) = bml.stat.betaprod(ab0(~incl_p, :));
    return;
end

for ii = 2:-1:1
    aa = a0(:,ii);
    bb = b0(:,ii);
    
    % mean
    mu0(:,ii) = aa ./ (aa + bb);
    
    % variance
    vr0(:,ii) = aa .* bb ./ ((aa + bb) .^ 2 .* (aa + bb + 1));
    
    % second moment
    mo0(:,ii) = vr0(:,ii) + mu0(:,ii) .^ 2;
end

% mean and variance of the product
mu = mu0(:,1) .* mu0(:,2);
mo = mo0(:,1) .* mo0(:,2);
vr = mo - mu .^ 2;

% parameters of the product

ab(:,1) = mu.^2 .* (1 - mu) ./ vr - mu;
ab(:,2) = ab(:,1) .* (1 - mu) ./ mu;

% % after Wikipedia, Method of Moments
% temp = (mu .* (1 - mu) ./ vr - 1);
% ab(:,1) = mu .* temp;
% ab(:,2) = (1 - mu) .* temp;

return;

%% Test
ab1 = [1 4; 1 4];
ab2 = [4 1; 0.5, nan];

mu1 = bml.stat.betamean(ab1);
mu2 = bml.stat.betamean(ab2);
vr1 = bml.stat.betavar(ab1);
vr2 = bml.stat.betavar(ab2);
mo1 = vr1 + mu1 .^ 2;
mo2 = vr2 + mu2 .^ 2;

ab = bml.stat.betaprod([ab1, ab2]);
mu = bml.stat.betamean(ab);
vr = bml.stat.betavar(ab);
mo = vr + mu .^ 2;

disp([mu1 .* mu2, mu]);
disp([vr1 .* vr2, vr]);
disp([mo1 .* mo2, mo]);