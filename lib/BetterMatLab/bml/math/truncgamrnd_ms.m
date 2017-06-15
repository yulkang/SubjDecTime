function r = truncgamrnd_ms(m, s, lb, ub, siz)
% r = truncgamrnd_ms(m, s, lb, ub, siz)
%
% See also: demo_truncgamrnd_ms

if nargin < 3 || isempty(lb)
    lb = 0;
end
if nargin < 4 || isempty(ub)
    ub = inf;
end
assert(all(lb <= ub));
if nargin < 5 || isempty(siz)
    [m, s] = rep2match(m, s);
    siz = size(m);
% else
%     m = rep2fit(m, siz);
%     s = rep2fit(s, siz);
end

%% Rejection: 0.9s / 1e6, but wrong - rejection probability needs to be sampled
% r = gamrnd_ms(m, s, siz);
% within_bound = (lb <= r) & (r <= ub);
% if ~all(within_bound)
%     m = rep2fit(m, siz);
%     s = rep2fit(s, siz);
%     
%     while ~all(within_bound)
%         r(~within_bound) = gamrnd_ms(m(~within_bound), s(~within_bound));
%         within_bound = (lb <= r) & (r <= ub);
%     end
% end

%% Inversion - 1.5s / 1e6
r = rand(siz);
p_lb = gamcdf_ms(lb, m, s);
p_ub = gamcdf_ms(ub, m, s);
p = (p_ub - p_lb) .* r + p_lb;
r = gaminv_ms(p, m, s);

if any(p_ub == p_lb)
    r(p_ub == p_lb) = p_lb;
end

