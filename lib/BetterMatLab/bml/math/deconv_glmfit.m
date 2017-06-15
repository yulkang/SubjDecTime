function [q, r, stat] = deconv_glmfit(b, a, nlag, varargin)
% [q, r, stat] = deconv_glmfit(b, a, nlag, varargin)

if nargin < 4, varargin = {'normal'}; end

nb = length(b);
na = length(a);

if nargin < 3, nlag = ceil(nb * 0.9); end

X = zeros(nb, nlag);

for ii = 1:nlag
    X(ii:end, ii) = a(1:(end-ii+1));
end

[q, ~, stat] = glmfit(X, b(:), varargin{:});

q = q(2:end) + q(1);
r = stat.resid;