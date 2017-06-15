function [r, plo, pup, p] = truncnormrnd1(lb, ub, siz)
% [r, plo, pup, p] = truncnormrnd_constparam(lb, ub, siz)
% Correctly handles sig == 0 and sig == eps.
%
% Note: Only ~10% faster than truncnormrnd.
%
% See also truncnormrnd
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
assert(ismatrix(lb) && ismatrix(ub));
if nargin < 3
    if ~isequal(size(lb), size(ub))
        [lb, ub] = rep2match(mu, sig, lb, ub);
    end
    siz = size(lb);
end
r = rand(siz);

bnd = cat(3, lb, ub);

pbnd = normcdf(bnd);
plo = pbnd(:,:,1);
pup = pbnd(:,:,2);
p   = (pup - plo) .* r + plo;
r   = norminv(p);
end