function log_p = logmvnpdf(x, mu, covmat)
% log(mvnpdf(x, mu, covmat)).
% x(i,j): i-th sample on j-th dimension.
% mu: row vector.
% covmat: square matrix.

n_dim = size(mu, 2);
assert(isequal(size(mu), [1, n_dim]));
assert(isequal(size(covmat), [n_dim, n_dim]));

x = bsxfun(@minus, x, mu);
log_p = -(x / covmat * x') ./ 2 ...
    - (log(norm(covmat)) + n_dim * (2 * pi)) ./ 2;
end