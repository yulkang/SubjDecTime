function [n_aft, n_bef] = set_n_tick(ax, kind, n_min, n_max)
assert(ismember(kind, {'XTick', 'YTick'}));

if ~exist('kind', 'var')
    kind = 'YTick';
end
if ~exist('n_min', 'var')
    n_min = 3;
end
assert(n_min >= 2);
if exist('n_max', 'var')
    assert((n_max + 1) / 2 + 1 >= n_min);
%     assert((n_min - 1 - 1) * 2 + 1 <= n_max); % satisfied if above is.
else
    n_max = (n_min - 1) * 2 + 1;
end

ticks_bef = get(ax, kind);
n_bef = length(ticks_bef);
if n_bef < 2
    warning('Cannot change count when there is only one tick!');
    return;
end
if n_bef < n_min
    n_fac = ceil((n_min - 1) / (n_bef - 1));
    n_aft = n_bef * n_fac;
elseif n_bef > n_max
    n_fac = ceil(n_bef / n_max);
    n_aft = n_bef / n_fac;
end

if n_aft < n_min || n_aft > n_max
    warning(['n_aft out of range - perhaps algorithm is wrong:\n' ...
             'n_bef=%d, n_aft=%d, n_min=%d, n_max=%d\n'], ...
             n_bef, n_aft, n_min, n_max);
end