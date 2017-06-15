function [d, d_sep] = kldivergence(p1, p2)
% If multidimensional, works on the first dimension. Uses log2().
%
% [d, d_sep] = kldivergence(p1, p2)
% : computes D_KL(p1 || p2)

assert(isequal(size(p1), size(p2)));

d_sep = p1 .* (log2(p1) - log2(p2));
d_sep(p1 == 0) = 0;
d = nansum(d_sep);



