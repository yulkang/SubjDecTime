function v = betavar(ab)
% variance of the beta distribution
%
% v = betavar(ab)
%
% ab(:,1) : alpha
% ab(:,2) : beta

a = ab(:,1);
b = ab(:,2);

v = a .* b ./ ((a + b) .^ 2 .* (a + b + 1));