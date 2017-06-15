function y = logdirpdf(x, alpha)
% y = logdirpdf(x, alpha)
%
% x : N-by-d or N-by-(d+1) matrix.
% alpha : 1-by-(d+1) or N-by-(d+1) matrix.
%
% y : N-by-1 vector of log(dirpdf(x, alpha)).
%
% See also: dirpdf
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

d = size(alpha, 2) - 1;

if size(x, 2) == d
    x(:, d + 1, :) = min(max(1 - sum(x, 2), eps), 1 - eps);
else
    assert(size(x, 2) == d + 1);
end
s = sum(x, 2);
assert(~any(s(:) > 1 + 1e-10) && ~any(s(:) <= 0));

% Approximate to avoid under/overflow.
x = max(x, eps); 
x = min(x, 1 - eps);

if all(sum(alpha, 2) == (d + 2))
    % If all histograms contain exactly one observation,
    % use a more efficient algorithm
    
    y = -gammaln(d + 1) + log(sum(bsxfun(@times, x, alpha == 2), 2));
else
    % if isrow(x) && ~isrow(alpha)
    %     n = size(alpha, 1);
    %     x = repmat(x, [n, 1]);
    %     
    % elseif ~isrow(x) && isrow(alpha)
    %     n = size(x, 1);
    %     alpha = repmat(alpha, [n, 1]);
    % end

    y = gammaln(sum(alpha, 2)) - sum(gammaln(alpha), 2) ...
        + sum(bsxfun(@times, alpha - 1, log(x)), 2);

    % y(any(x == 0, 2)) = -inf;
end