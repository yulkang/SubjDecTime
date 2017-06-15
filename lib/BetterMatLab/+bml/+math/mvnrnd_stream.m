function r = mvnrnd_stream(RStream, mu, sigma, n)
% r = mvnrnd_stream(RStream, mu, sigma, n)
d = numel(mu);

if isvector(sigma)
    sigma = diag(sigma);
    r = bsxfun(@plus, randn(RStream, n, d) * sqrt(sigma), mu(:)');
else    
    [T, e] = cholcov(sigma);
    if e ~= 0
        error('sigma may not be positive definite!');
    end
    r = bsxfun(@plus, randn(RStream, n, d) * T, mu(:)');
end