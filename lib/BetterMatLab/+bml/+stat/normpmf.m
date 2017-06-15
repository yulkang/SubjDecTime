function out = normpmf(v, m, sd)
% out = normpmf(v, mean, sd)
%
% Always normalized along the first dimension.
siz = size(v);
dv = v(2) - v(1);
v  = [v(1) - dv/2; v(:) + dv/2];

if nargin < 4
    dim = 1;
end

out = diff(normcdf(v, m, sd));
out = reshape(out, siz);
end