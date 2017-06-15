function res = dist2(x1, x2, dim)
% DIST2     Squared distance between two multidimensional coordinates.
%
% res = dist2(x1, x2, dim)
%
% dim   : Along which dimension of the array the spatial dimension increases.
%         Defaults to 1.

if nargin < 3, dim = 1; end

res = sum(bsxfun(@minus, x1, x2), dim);
end