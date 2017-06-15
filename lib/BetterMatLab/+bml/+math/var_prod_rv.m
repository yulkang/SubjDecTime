function v = var_prod_rv(rv1, rv2)
% v = var_prod_rv(rv1, rv2)
v = mean(rv1.^2) .* mean(rv2.^2) - mean(rv1).^2 .* mean(rv2).^2;
