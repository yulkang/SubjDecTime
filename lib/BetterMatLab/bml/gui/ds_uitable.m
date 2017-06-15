function v = ds_uitable(h, op, row, col, v)
% v = ds_uitable(h, op, row, col, v)
% 
% h         : handle to a uitable.
% op        : 'get' or 'set'
% row, col  : numeric, logical, or string index
% v         : cell array.

if nargin < 3, row = ':'; end
if nargin < 4, col = ':'; end

d    = get(h, 'Data');
siz  = size(d);

if isnumeric(row) || islogical(row) || isequal(row, ':')
    row = ix2py(row, siz(1));
else
    row = strcmpfinds(row, get(h, 'RowName'));
end
if isnumeric(col) || islogical(col) || isequal(col, ':')
    col = ix2py(col, siz(2));
else
    col = strcmpfinds(col, get(h, 'ColumnName'));
end

switch op
    case 'set'     
        d(row, col) = v;
        set(h, 'Data', d);
        
    case 'get'
        v = d(row, col);
end
end