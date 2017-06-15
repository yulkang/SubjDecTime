function [d, d_sep] = jsdivergence(p1, p2)
% Jensen-Shannon divergence between two distributions.
%
% [d, d_sep] = jsdivergence(p1, p2)

d = bml.math.entropy_shannon((p1 + p2) ./ 2) ...
    - bml.math.entropy_shannon(p1) ./ 2 ...
    - bml.math.entropy_shannon(p2) ./ 2;

% % Unstable when p1 or p2 contains zero.
%
% m = (p1 + p2) ./ 2;
% 
% d = (nan0(bml.math.kldivergence(p1, m)) ...
%     + nan0(bml.math.kldivergence(p2, m))) ./ 2;

if nargout >= 2
    m = (p1 + p2) ./ 2;
    
    [~, kl1] = bml.math.kldivergence(p1, m);
    [~, kl2] = bml.math.kldivergence(p2, m);
    d_sep = (nan0(kl1) + nan0(kl2)) ./ 2;
end    
