function tbl = set_mat_by_col(tbl, name, mat)
% ds = set_mat_by_col(ds, name, mat)
%
% ds.(name_K) = mat(:,K)

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.
n_col = size(mat, 2);
for i_col = 1:n_col
    name1 = sprintf('%s_%d', name, i_col);
    tbl.(name1) = mat(:, i_col);
end