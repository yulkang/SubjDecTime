function [u, ia, ic] = uniquenan(m, v, varargin)
% Treat NaNs as identical.
% [u, ia, ic] = uniquenan(m, v=inf, ...)
% 
% v: the value that temporarily substitutes nan. Should be absent in m.
if nargin < 2
    v = inf;
end
m(isnan(m)) = v;
[u, ia, ic] = unique(m, varargin{:});
u(u == v) = nan;
