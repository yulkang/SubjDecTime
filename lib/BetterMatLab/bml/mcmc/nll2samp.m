function samp = nll2samp(x, nll, n_samp, n_burnin)
% samp = nll2samp(x, nll, n_samp, n_burnin)
assert(isvector(nll));
if nargin < 3
    n_samp = 1000;
end
if nargin < 4
    n_burnin = round(n_samp * 0.05);
end
if isrow(x)
    if length(x) == length(nll)
        x = x';
    else
        error('If x is a vector, its length must match nll!');
    end
end
len = size(x,1);

Samp = MetropolisHastings;

x0 = randi(len);
samp = Samp.sample_logodds(x0, n_samp + n_burnin, ...
    @(x1, x0) nll(bsxEq(x,x1)) - nll(bsxEq(x,x0)), ...
    @(x1, x0) 0, ...
    @(x0) x(randi(len)));

samp = samp(n_burnin + (1:n_samp));
end