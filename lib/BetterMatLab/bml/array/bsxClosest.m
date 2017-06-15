function [ixMin, dstMin] = bsxClosest(v, rep, op)
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

% Efficiently compute all distance.
dst             = bsxfun(@minus, rep(:)', v(:));
        
% Exclude entries accoring to OP.
if ~exist('op', 'var'), op = 'abs'; end
switch op
    case 'lt'
        dst(dst>=0) = nan;
        
    case 'le'
        dst(dst>0)  = nan;
        
    case 'gt'
        dst(dst<=0) = nan;
        
    case 'ge'
        dst(dst<0)  = nan;
end
        
% Find out minimum distance entries. NaN entries are excluded.
[~, ixMin] = min(abs(dst), [], 2);
dstMin = dst(sub2ind(size(dst), (1:size(dst,1))', ixMin));

% If no entry meets criterion, set the index as NaN.
ixMin(isnan(dstMin)) = nan;

% Reshape to match v's size.
dstMin = reshape(dstMin, size(v));
ixMin  = reshape(ixMin,  size(v));