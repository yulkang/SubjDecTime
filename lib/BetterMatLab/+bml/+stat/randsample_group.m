function ix = randsample_group(group)
% Random sample with replacement within each unique group.
%
% ix = randsample_group(group)
%
% group(tr, :) : group identifier.
% ix(tr, 1) : resampled index.

[~,~,g] = unique(group, 'rows');
n_gr = max(g);
n_tr = size(group, 1);

ix = zeros(n_tr, 1);
for gr = 1:n_gr
    incl = g == gr;
    ix0 = find(incl);
    n_incl = length(ix0);
    
    ix(incl) = ix0(randsample(n_incl, n_incl, true));
end