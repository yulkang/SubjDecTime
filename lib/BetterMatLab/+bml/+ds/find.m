function [res, row] = find(ds, row, col)
% [res, row_ix] = find(ds, row, col)
%
% ds : dataset or table.
%
% row : search criteria. One of:
% - numeric or logical indices
% - a function handle that returns indices with ds as an input
% - a cell array with name, value pairs
% - a struct with fields as column names and values
%
% row in the output is always a numerical index vector.
%
% col : column(s).
%
% res : found data.
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

if isa(row, 'function_handle')
    row = row(ds);
end
if isstruct(row)
    row = varargin2C(row);
end
if iscell(row)
    if size(row, 1) > 1
        row = varargin2C(row);
    end
    incl = true(size(ds, 1), 1);
    for ii = 1:2:numel(row)
        nam = row{ii};
        val = row{ii + 1};
        val0 = ds.(nam);
        if ischar(val0)
            val0 = cellstr(val0);
        end
        
        if ischar(val)
            incl = incl & strcmp(val0, val);
        elseif isscalar(val)
            if iscell(val)
                incl = incl & cellfun(@(c) isequal(c, val{1}), val0);
            else
                incl = incl & (val0 == val);
            end
        elseif iscell(val) && ~isempty(val) && ischar(val{1})
            incl = incl & ismember(val0, val);
        else
            error('Not implemented yet!');
        end
    end
    row = incl;
end
if islogical(row)
    row = find(row);
end
assert(isnumeric(row));

% subsref
if ~exist('col', 'var')
    res = ds(row, :);
elseif ischar(col)
    res = ds.(col)(row, :);
else
    res = ds(row, col);
end
end