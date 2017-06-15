function varargout = discretize(varargin)
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
[varargout{1:nargout}] = discretize(varargin{:});