function tf = eq_tol(a, b, tol)
% tf = eq_tol(a, b, [tol = 1e-3])

if ~exist('tol', 'var'), tol = 1e-3; end

tf = abs(a - b) <= tol;