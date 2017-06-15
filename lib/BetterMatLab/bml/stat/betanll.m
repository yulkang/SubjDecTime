function nll = betanll(ab, p)
% nll = betanll(ab, p)
%
% nll(k,1) = negative log likelihood of p(k) given Beta(ab(k,1), ab(k,2))
assert(isvector(p));
assert(length(p) == size(ab, 1));
assert(size(ab, 2) == 2);
incl = ~isnan(p);
if any(~incl)
    if any(incl)
        nll = zeros(size(p));
        nll(incl) = bml.stat.betanll(ab(incl,:), p(incl));
    end
    nll(~incl) = nan;
    return;
end

p = min(max(p, eps), 1 - eps);

a = ab(:,1);
b = ab(:,2);

nll = (a - 1) .* log(p) + (b - 1) .* log(1 - p) ...
    + gammaln(a + b) - gammaln(a) - gammaln(b);
nll = -nll;

