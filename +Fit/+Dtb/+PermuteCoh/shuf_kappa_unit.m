function [p_incl_d0, p_excl_d0] = shuf_kappa_unit(kappa)

f_mean_dist = @(v) mean((v(:,2) - v(:,1)).^2);

n_incl = size(kappa, 1);
incl = 1:n_incl;

ix = perms(incl);
n_perm = size(ix, 1);

d = zeros(n_perm, 1);
v1 = kappa;
for i_perm = 1:n_perm
    r = ix(i_perm,:);
    v1(incl,2) = kappa(r,2);
    d(i_perm) = f_mean_dist(v1);
end

d0 = f_mean_dist(kappa);
p_incl_d0 = mean(d <= d0); % North 2002, 2003
p_excl_d0 = (sum(d <= d0) - 1) / (n_perm - 1);