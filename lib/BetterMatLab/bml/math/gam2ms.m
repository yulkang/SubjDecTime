function [m, s] = gam2ms(a, b)
% [m, s] = gam2ms(a, b)

if nargin < 2, b = a(2); a = a(1); end

m = a .* b;
s = sqrt(a .* b.^2);

if nargout < 2, m = [m s]; end