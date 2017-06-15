function r = truncgamrnd_ms_discrete(m, s, lb, ub, siz, t)
% r = truncgamrnd_ms(m, s, lb, ub, siz, t)
%
% Fast sampling from a given set of discrete points t.
%
% See also: truncgamrnd_ms

error('Not implemented yet!');
% Get unique combinations of m and s, then get number of repetitions for each

persistent t0 F0

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
if nargin < 6 || isempty(t)
    assert(~isempty(t0));
elseif isempty(t0) || ~isequal(t0, t)
    t0 = t;
    % Calculate proportions
    F0 = gamcdf_ms(t, m, s);
end

%% Inversion
r = rand(siz);
p_lb = gamcdf_ms(lb, m, s);
p_ub = gamcdf_ms(ub, m, s);
p = (p_ub - p_lb) .* r + p_lb;
r = gaminv_ms(p, m, s);

if any(p_ub == p_lb)
    r(p_ub == p_lb) = p_lb;
end

