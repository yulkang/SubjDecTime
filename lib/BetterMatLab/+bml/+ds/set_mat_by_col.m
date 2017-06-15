function ds = set_mat_by_col(ds, name, mat)
% ds = set_mat_by_col(ds, name, mat)
%
% ds.(name_K) = mat(:,K)

n_col = size(mat, 2);
for i_col = 1:n_col
    name1 = sprintf('%s_%d', name, i_col);
    ds.(name1) = mat(:, i_col);
end