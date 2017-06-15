function resid = regress_out(y, X)
% resid = regress_out(y, X)
X = mlab_mod.stat.remove_collinear(X);

[~, ~, resid] = regress(y, [ones(size(X,1),1), X]);
end