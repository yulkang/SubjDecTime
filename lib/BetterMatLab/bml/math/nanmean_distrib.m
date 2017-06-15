function m = nanmean_distrib(p, v, d)
% m = nanmean_distrib(prob, [value=1:size(prob,dim), dim=1])
%
% When value and probability are of different sizes, specify dimension 
% along which to average.
%
% See also std_distrib

if nargin < 3 || isempty(d)
    d = 1;
end
if nargin < 2 || isempty(v)
    v = reshape2vec(1:size(p, d), d);
end

if nargin >= 3
    m = nansum(bsxfun(@times, v, bsxfun(@rdivide, p, nansum(p, d))), d);
else
    try
        m = nansum(v .* (p ./ nansum(p)));
    catch
        m = nansum(bsxfun(@times, v, bsxfun(@rdivide, p, nansum(p))));
    end
end