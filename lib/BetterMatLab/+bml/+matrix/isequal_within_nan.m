function tf = isequal_within_nan(a, b, tol)
% tf = isequal_within_nan(a, b, tol=1e-6)
%
% EXAMPLE:
% >> bml.matrix.isequal_within_nan([1, nan, 1], [1+1e-7, nan, 1])
% ans =
%      1
%
% >> bml.matrix.isequal_within_nan([1, nan, 1], [1+1e-7, nan, 2])
% ans =
%      0
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
     
if nargin < 3, tol = 1e-6; end

dif = abs(a - b);
tf = all(vVec((dif <= tol) | (isnan(a) & isnan(b))));