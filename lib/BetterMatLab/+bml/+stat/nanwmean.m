function m = nanwmean(v, w, varargin)
% Weighted mean ignoring nans. 
% If either v or w is nan, it is considered missing.
%
% EXAMPLE:
% >> bml.stat.nanwmean([1 2 3; 4 5 nan], [3 nan 1; 1 1 1], 2)
% ans =
%     1.5000
%     4.5000
% 
% See also: wmean

incl = bsxfun(@and, ~isnan(v), ~isnan(w));
w = bsxfun(@times, w, incl);

sum_w = nansum(w, varargin{:});
sum_v = nansum(bsxfun(@times, v, w), varargin{:});

m     = bsxfun(@rdivide, sum_v, sum_w);