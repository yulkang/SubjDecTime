function v = sign_tol(v, tol)
% sign_tol  Gives + or - sign only if abs(v) > tol.
%
% v = sign_tol(v, [tol=0.001])

if ~exist('tol', 'var'), tol = 0.001; end

v = (v > tol) - (v < -tol);