function tf = isequal_within(a, b, tol)
% tf = isequal_within(a, b, tol=1e-6)

if nargin < 3, tol = 1e-6; end

dif = abs(a - b);
tf = max(dif(:)) <= tol;