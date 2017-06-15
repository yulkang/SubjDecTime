function s = inf2v(s, v)
% s = inf2v(s, v)

if nargin < 2, v = 0; end
s(~isfinite(s)) = v;