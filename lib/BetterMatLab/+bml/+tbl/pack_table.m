function tbl = pack_table(varargin)
% tbl = pack_table(var1, var2, ...)
%
% same as table(var1, var2, ...) except matrices 
% are set by set_mat_by_col.

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

n_col = numel(varargin);
tbl = table;

for i_col = 1:n_col
    name = inputname(i_col);
    
%     if size(varargin{i_col}, 2) > 1
        tbl = bml.tbl.set_mat_by_col(tbl, name, varargin{i_col});
%     else
%         tbl.(name) = varargin{i_col};
%     end
end