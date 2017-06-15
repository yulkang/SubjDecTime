function ix = prop2ind(p, n)
% Gets proportions between 0 and 1 and gives indices between 1 and n.
%
% ix = prop2ind(p, n)
%
% n is either a scalar or a vector.
% p is any array (if n is a scalar) or a matrix (if n is a vector).
% ix has the same size as p.

if length(n) == 1
    ix = minmax(round(p * n), 1, n);
else
    ix = zeros(size(p));
    
    for ii = 1:length(n)
        ix(:,ii) = minmax(round(p(:,ii) * n(ii)), 1, n(ii));
    end
end