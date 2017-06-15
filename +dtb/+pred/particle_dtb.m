function D = particle_dtb(drift, t, Bup, Blo, y_axis, p0, notabs_flag, sigmaSq, n_sim)
% D = particle_dtb(drift, t, Bup, Blo, y_axis, p0, notabs_flag, sigma, n_sim)
% drift(cond, k)
% t(k) time in seconds
% Bup, Blo(cond, k): Bound
% y_axis(ev) evidence levels to compute unabsorbed density. Give empty to skip.
% p0(ev, cond, k): probability of the evidence.
% notabs_flag : Give 1 to save the unabsorbed density.
% sigma(cond, k)
% n_sim: defaults to 100.
%
% 2016 Yul Kang. hk2699 at columbia dot edu.

assert(isrow(t));
nk = length(t);
n_cond = size(drift, 1);
n_particle = n_cond * n_sim;
ix_cond = repmat((1:n_cond)', [n_sim, 1]);

y = zeros(n_particle, 1);
wt = ones(n_particle, 1);
unabs = true(n_particle, 1);
n_unabs = nnz(wt);

drift = rep2fit(drift, [n_particle, nk]);
% Bup = rep2fit(Bup, [n_particle, nk]);
% Blo = rep2fit(Blo, [n_particle, nk]);
sigmaSq = rep2fit(sigmaSq, [n_particle, nk]);

% Transform bound to remove drift.
% cum_drift = [zeros(n_particle, 1), ...
%     cumsum(bsxfun(@times, drift(:,1:(end-1)), diff(t)), 2)];
% Bup = Bup - cum_drift;
% Blo = Blo - cum_drift;

wt_all = zeros(n_particle, nk);
wt_all(:,1) = 1;
y_all = nan(n_particle, nk);
y_all(:,1) = 0;
unabs_all = true(n_particle, nk);

p_abs_up = zeros(n_particle, nk);
p_abs_lo = zeros(n_particle, nk);

for k = 2:nk
    dt = t(k) - t(k - 1);    
    sigmaSq_eff = sigmaSq(:,k) .* dt;
    
    n_unabs = nnz(unabs);
    dy = randn([n_unabs, 1]) .* sqrt(sigmaSq_eff(unabs)) ...
       + drift(unabs,k) .* dt;
    y(unabs) = y(unabs) + dy;
    y_all(unabs,k) = y(unabs);
    
    abs_up = y(unabs) > Bup(1,k); % Bup(unabs,k);
    abs_lo = y(unabs) < Blo(1,k); % Blo(unabs,k);

    p_abs_up(unabs, k) = p_abs_up(unabs, k) + abs_up;
    p_abs_lo(unabs, k) = p_abs_lo(unabs, k) + abs_lo;

%     p_abs_up(unabs, k) = p_abs_up(unabs, k) + abs_up .* wt(unabs);
%     p_abs_lo(unabs, k) = p_abs_lo(unabs, k) + abs_lo .* wt(unabs);
    
    % Unabsorbed
    unabs(unabs) = (~abs_up) & (~abs_lo);
    unabs_all(:,k) = unabs;

%     n_unabs = nnz(unabs);
%
%     Blo_rel = (Blo(unabs,k) - y(unabs)) ./ sigmaSq_eff(unabs);
%     Bup_rel = (Bup(unabs,k) - y(unabs)) ./ sigmaSq_eff(unabs);
%     
%     bound_p = normcdf([Blo_rel; Bup_rel]);
%     
%     Blo_p = bound_p(1:n_unabs) .* wt(unabs);
%     Bup_p = (1 - bound_p((1:n_unabs) + n_unabs)) .* wt(unabs);
%     
%     p_abs_up(unabs, k) = p_abs_up(unabs, k) + Bup_p;
%     p_abs_lo(unabs, k) = p_abs_lo(unabs, k) + Blo_p;
%     
%     wt(unabs) = wt(unabs) - Blo_p - Bup_p;
%     wt_all(unabs,k) = wt(unabs);
end

%% Output
p_lo = squeeze(nanmean(reshape(p_abs_lo, [n_cond, n_sim, nk]), 2));
p_up = squeeze(nanmean(reshape(p_abs_up, [n_cond, n_sim, nk]), 2));

D = packStruct(p_lo, p_up, p_abs_lo, p_abs_up, y_all, wt_all, unabs_all);
return;
