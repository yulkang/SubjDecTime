function src = nan2v(src, v)
% Replace NaNs with v.
%
% res = nan2v(src, [v=0])
%
% See also: nan0
if nargin < 2, v = 0; end

src(isnan(src)) = v;