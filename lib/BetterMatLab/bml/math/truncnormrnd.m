function [r, plo, pup, p] = truncnormrnd(mu, sig, lb, ub, siz)
% [r, plo, pup, p] = truncnormrnd(mu, sig, lb, ub, siz)
% Correctly handles sig == 0 and sig == eps.
%
% When giving multiple mu, sig, lb, and ub, try giving them as a row vector,
% and specify siz as [n_samp x n_param]. That may be faster.
%
% See also truncnormrnd_constparam
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
[mu, sig, lb, ub] = rep2match({mu, sig, lb, ub});
if nargin < 5
    siz = size(mu);
end
assert(all(sig >= 0));
% assert(all((lb <= mu) & (ub >= mu) & (sig >= 0))); % Doesn't need to be the case
r = rand(siz);

plo = normcdf(lb, mu, sig);
pup = normcdf(ub, mu, sig);
p   = bsxfun(@plus, bsxfun(@times, pup - plo, r), plo);

if (size(p,1) > 1) && (size(mu,1) == 1) && (size(sig,1) == 1)
    n_param = size(p, 2);
    for i_param = 1:n_param
        if sig(i_param) == 0
            r(:,i_param) = mu(i_param);
        else
            r(:,i_param) = norminv(p(:,i_param), mu(i_param), sig(i_param));
        end
    end
else
    r   = norminv(p, mu, sig);
    r(sig == 0) = mu(sig == 0);
end
return;

%% Demo
mu = 0;
sd = [0.5 1 2];
lb = [-1, -1.5, -2];
ub = [0.5,   1,  4];
n_samp = 10000;
n_param = length(sd);

r = truncnormrnd(mu, sd, lb, ub, [n_samp, n_param]);
for ii = 1:n_param
    subplot(n_param, 1, ii);
    hist(r(:,ii), 50);
end