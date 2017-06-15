function var_prod = var_prod_rv_summary(mean_rvs, var_rvs)
% var_prod = var_prod_rv_summary(mean_rvs, var_rvs)
assert(numel(mean_rvs) == 2);
assert(numel(var_rvs) == 2);

var_prod = mean_rvs(1) .^ 2 .* var_rvs(2) ...
         + mean_rvs(2) .^ 2 .* var_rvs(1) ...
         + var_rvs(1) .* var_rvs(2);