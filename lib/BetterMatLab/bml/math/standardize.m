function [res, avg, stdev] = standardize(src, dim)
% [res, avg, stdev] = standardize(src, dim)
%
% center src and divide by standard deviation.
% if src has more than two dimensions, works along the first dimension.

if nargin < 2
    if isvector(src)
        dim = find(size(src) > 1, 1, 'first');
        if isempty(dim)
            dim = 1;
        end
    else
        dim = 1;
    end
end

avg = nanmean(src, dim);
stdev = nanstd(src, dim);

res = bsxfun(@rdivide, bsxfun(@minus, src, avg), stdev);
