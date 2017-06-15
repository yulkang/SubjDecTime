function [dst, boundary, n_rep] = discretize(src, arg, varargin)
% DISCRETIZE    Discretize continuous data.
%
% [dst, boundary] = discretize(src, nBin)
% [dst, boundary] = discretize(src, nBin, vMin, vMax)
% [dst, boundary] = discretize(src, [boundary1, boundary2, ...], 'rel')
% [dst, boundary] = discretize(src, [boundary1, boundary2, ...], 'abs')
% [dst, rep, n_rep] = discretize(src) % Same as discretize(src, 'unique')
% [dst, rep, n_rep] = discretize(src, 'unique', [rep])
% [dst, rep, n_rep] = discretize(src, 'unique_col', [rep])
% : discretize every unique value, separately for each column.
%
% dst(I) = K if boundary(K-1) < src(I) <= boundary(K).
%
% 'rel' specifies boundaries in 0..1 range, 
% but the output boundaries are always absolute values.
% 
% EXAMPLE:
% >> magic(3)
% ans =
%      8     1     6
%      3     5     7
%      4     9     2
% >> discretize(magic(3), 'unique_col')
% ans =
%      3     1     2
%      1     2     3
%      2     3     1        
%
% See also quantilize, histD

if nargin < 2 || ischar(arg) && strcmp(arg, 'unique')
    if ~isempty(varargin)
        rep = varargin{1};
    else
        rep = unique(src);
    end
    dst      = bsxFind(src(:), rep(:)');
    dst      = reshape(dst, size(src));
    boundary = rep;
    n_rep    = length(rep);
    
elseif ischar(arg) && strcmp(arg, 'unique_col')
    n_col    = size(src, 2);
    dst      = zeros(size(src));
    boundary = cell(1, n_col);
    rep      = cell(1, n_col);
    n_rep    = zeros(1, n_col);
    
    if ~isempty(varargin)
        rep = varargin{1};
    else
        for col = 1:n_col
            rep{col} = unique(src(:,col));
        end
    end
    
    for col = 1:size(src, 2)
        [dst(:,col), boundary{col}, n_rep(col)] = ...
            discretize(src(:,col), 'unique', rep{col});
    end

elseif isempty(varargin) || length(varargin)>=2
    
    if length(arg) ~= 1
        error(['nBin should be a scalar; ' ...
               'for boundaries, specify ''rel'' or ''abs''!']); 
    else
        nBin = arg;
    end
    
    if ~isempty(varargin)
        minV = varargin{1};
        maxV = varargin{2};
    else
        minV = min(src(:));
        maxV = max(src(:));        
    end
    rangeV = maxV - minV;
        
    dst = min(max(ceil((src - minV) .* (nBin ./ rangeV)), 1), nBin);
    
    boundary = linspace(minV, maxV, nBin+1);
    n_rep = nBin;
    
else
    minV = min(src(:));
    maxV = max(src(:));
    rangeV = maxV - minV;
    
    boundary = arg;

    if strcmp(varargin{1}, 'rel')
        if max(boundary) < 1, boundary = [boundary 1]; end

        boundary = sort(boundary) .* rangeV + minV;

    elseif strcmp(varargin{1}, 'abs')
        if max(boundary) < maxV, boundary = [boundary maxV]; end

        boundary = sort(boundary);
    end

    dst = arrayfun(@(c) find(c<=boundary, 1, 'first'), src);
end