function varargout = bsxClosest(varargin)
% BSXCLOSEST Finds closest number and returns index.
%
% [ixMin, dstMin] = bsxClosest(v, rep, [op='abs'])
%
% To avoid confusion, give v and rep as vectors.
% If the closest entry is not unique, gives the smallest index.
%
% op : 'abs' (default), 'lt', 'le', 'gt', or 'ge'.
%   abs : minimum absolute distance
%   lt  : minimum distance rep that is less than each element of v.
%   le  : minimum distance rep that is less than or equal to ..
%   gt, ge: greater than, greater than or equal to.
%
% ixMin(k)  : Index of closest element of rep to v(k).
% dstMin(k) : rep(ixMin(k)) - v(k). Can be either positive or negative.
%
% ixMin and dstMin have the same size as v.
%
% Example:
% [y, ix] = min([1 2 3; 1 3 2],[],1)
% y  =     1     2     2
% ix =     1     1     2
%
% See also: BSXEQ, BSXFIND, BSXFUN, MIN.
%
% 2013 (c) Yul Kang
[varargout{1:nargout}] = bsxClosest(varargin{:});