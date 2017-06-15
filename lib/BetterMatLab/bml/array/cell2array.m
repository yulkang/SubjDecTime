function A = cell2array(C, cell_dim_first)
% A = cell2array(C, cell_dim_first=false)

if ~exist('cell_dim_first', 'var'), cell_dim_first = false; end

ndims_C = ndims(C);
ndims_A = ndims(C{1});

A = cell2mat(permute(C, [ndims_C + (1:ndims_A), 1:ndims_C]));

if cell_dim_first
    A = permute(A, [ndims_A + (1:ndims_C), 1:ndims_A]);
end