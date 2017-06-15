function [b, m] = vincentilize(v, vin)
% [b, m] = vincentilize(v, vin)
%
% % v(k): number of elements at index k.
% % vin : number of elements per vin.
%
% % b(k): Index of boundary between vincentile k-1 and k.
% b(k) = find(cumsum(v) > vin * k, 1, 'first');
%
% % m(k): Middle point between boundaries.
% m(k) = (b(k) + b(k+1)) / 2;   % b(0) is treated as 0.
%
% EXAMPLE:
% vincentilize([0 1 1 2 1 1 0], 2)
% ans =
%      0   3   4   6
% 
% vincentilize([0 1 1 2 1 1 0], 3)
% ans =
%      0   4   6

assert(isvector(v), 'Only give a vector!');

c  = cumsum(v(:));
c  = diff([0; floor(c / vin)]);
b  = [0; find(c)];

if nargout >= 2
    m = (b(1:(end-1)) + b(2:end) + 1) / 2;
    if size(v, 2) > 1, m = m'; end
end

if size(v, 2) > 1, b = b'; end

