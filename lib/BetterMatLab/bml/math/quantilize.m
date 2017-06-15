function [dst, boundary, s, dst_s] = quantilize(src, n, dim, varargin)
% QUANTILIZE  gives which quantile each data belongs to.
%
% dst = quantilize(src, nBin)
% dst = quantilize(src, nBin, [dim = 1])
% dst = quantilize(src, boundary)
% dst = quantilize(src, boundary, [dim = 1])
% [dst, boundary, s, dst_s] = quantilize(...)
%
% dst       is always the same size as src.
% nBin      is length(boundary) + 1.
% boundary  is the quantile boundary.
% s         is the summary statistic for each quantile (defaults to @mean).
% dst_s     is the summary statistic for each element, corresponding to its quantile.
%
% OPTIONS (4th argument and on)
% -------
% 'summary',      @mean
%
% See also quantile, discretize, histD

S = varargin2S(varargin, {
    'summary',      @mean
    });

if nargin<2 || isempty(n), n = 10; end

if nargin<3 || isempty(dim)
    if size(src, 1) == 1
        dim = 2;
    else
        dim = 1; 
    end
end

%% Error checking
siz1 = size(src) > 1;
siz1(dim) = 0;

if any(siz1)
    error('Behavior except for vectors are erroneous yet!'); % TODO
end

%% 
if isscalar(n)
    if n == 2
        boundary = median(src, dim);
    else
        boundary = quantile(src, n-1, dim);
    end
else
    boundary = n;
    n = length(boundary) + 1;
end

cIncl    = true(size(src));
dst      = zeros(size(src));

for ii = 1:(n-1)
 newIncl = cIncl & (src <= boundary(ii));
 dst(newIncl) = ii;
 cIncl(newIncl) = false;
end

dst(cIncl) = n ;
notnan = ~isnan(src);

if nargout >= 3
    s = accumarray(vVec(dst(notnan)), vVec(src(notnan)), [n, 1], S.summary);
    
    % If src is a row vector, return a row vector.
    if size(src,1) == 1 && size(src,2) > 1
        s = s'; 
    end
    
    if nargout >= 4
        dst_s = s(dst);
    end
end

dst(isnan(src)) = 0; % disregard nan entries
