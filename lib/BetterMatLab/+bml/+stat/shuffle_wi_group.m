function tr = shuffle_wi_group(group0, tr0)
% tr = shuffle_wi_group(group0, [tr0])
%
% group0 : a matrix with N rows. Each unique row indicates a unique group.
% tr0 : original trial number. Defaults to (1:N)'.
% tr  : trial numbers shuffled within each unique rows of group0.
%
% See also test_shuffle_wi_group
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin < 2
    tr0 = (1:size(group0, 1))';
end

assert(iscolumn(tr0));
assert(ismatrix(group0));
assert(size(tr0, 1) == size(group0, 1));

[~, ~, group] = unique(group0, 'rows');
n_group = max(group);

tr = zeros(size(tr0));

for i_group = 1:n_group
    incl = find(group == i_group);
    n_incl = length(incl);

    tr(incl) = tr0(incl(randperm(n_incl)));
end
end
