function ds = ds_reorder_columns(ds, src, dst, is_bef)
% ds = ds_reorder_columns(ds, src, dst, [is_bef = true])
%
% EXAMPLE:
%
% >> ds = dataset({1, 'a'}, {'B', 'b'}, {3, 'c'}, {4, 'd'})
% ds = 
%     a    b    c    d
%     1    B    3    4
% 
% >> ds = ds_reorder_columns(ds, 'b', 'd')
% ds = 
%     a    c    b    d
%     1    3    B    4
% 
% >> ds = ds_reorder_columns(ds, {'a', 'b'}, '_end')
% ds = 
%     c    d    a    b
%     3    4    1    B
% 
% >> ds = ds_reorder_columns(ds, {'a', 'd'}, '_begin') 
% ds = 
%     a    d    c    b
%     1    4    3    B

if nargin < 4, is_bef = true; end

cols = ds.Properties.VarNames;
n_col = length(cols);

ix_src = strcmpfinds(src, cols);
ix_dst = find(strcmp(dst, cols));

cols_wo = setdiff(1:n_col, ix_src);

if strcmp(dst, '_end')
    ix_dst = length(cols_wo) + 1;
    is_bef = true;
    
elseif strcmp(dst, '_begin')
    ix_dst = 0;
    is_bef = false;
    
else
    ix_dst = find(cols_wo == ix_dst);
end

if is_bef
    ix_new = [cols_wo(1:(ix_dst - 1)), ix_src, cols_wo(ix_dst:end)];
else
    ix_new = [cols_wo(1:ix_dst), ix_src, cols_wo((ix_dst+1):end)];
end

% ds.Properties.VarNames = ds.Properties.VarNames(ix_new);
ds = ds(:,ix_new);