function v = nansem(v, d)
% v = nansem(v, d=1)

if nargin < 2 || isempty(d), d = 1; end

if isempty(v)
    v = nan; % Consistent with nanmean
    return;
end
v = bsxfun(@rdivide, nanstd(v,0,d), sqrt(max(sum(~isnan(v),d) - 1, 0)));