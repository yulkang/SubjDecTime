function ds = ds_cell2mat2(ds, varargin)
% Convert numeric fields of row vectors into matrix padded with NaN.

fs = ds.Properties.VarNames;
for f = fs(:)'
    v = ds.(f{1});
    if ~iscell(v) || isempty(v)
        continue;
    end
    if all(cellfun(@isnumeric, v)) && isrow(v{1})
        ds.(f{1}) = cell2mat2(v);
    end
end
end