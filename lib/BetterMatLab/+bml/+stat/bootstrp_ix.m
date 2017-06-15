function boot_ix = bootstrp_ix(n_boot, n_or_group)
% Sample with replacement, within group if specified.
%
% n_or_group can either be the number of trials (scalar),
% or the group number (vector). In the latter case, the number of trials
% is the length of the vector.
%
% group is a vector of integers from 1 to n_group, as in the third output
% of unique(). Give 0 where the trial should be excluded.
%
% boot_ix{i_boot} : an n-vector of trial numbers.
%
% EXAMPLE:
% >> cell2mat2(bml.stat.bootstrp_ix(10, [1 1 1 2 2]'))'
% ans =
%      2     1     1     3     3     1     2     1     2     2
%      1     1     2     1     3     1     3     2     3     3
%      2     3     2     2     1     1     2     1     2     1
%      4     5     4     5     5     4     5     5     4     4
%      4     5     4     4     5     4     4     4     4     5
%
% 2016 Yul Kang. hk2699 at columbia dot edu.
if isscalar(n_or_group)
    n_tr = n_or_group;
    group = ones(n_tr, 1);
else
    n_tr = length(n_or_group);
    group = n_or_group;
end
n_group = max(group);

boot_ix = cell(1, n_boot);
for i_boot = 1:n_boot
    boot_vec = zeros(n_tr, 1);
    
    for i_group = 1:n_group
        incl = group == i_group;
        n_incl = nnz(incl);
        
        r = randsample(n_incl, n_incl, true);
        ix_incl = find(incl);
        boot_vec(incl) = ix_incl(r);
    end
    
    boot_ix{i_boot} = boot_vec;
end