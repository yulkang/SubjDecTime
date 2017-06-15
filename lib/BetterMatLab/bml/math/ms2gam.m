function [a, b] = ms2gam(m, s)
% [a, b] = ms2gam(m, s)

if nargin < 2, s = m(2); m = m(1); end

a = m.^2 ./ (s.^2);
b = (s.^2) ./ m;

if nargout < 2, a = [a, b]; end