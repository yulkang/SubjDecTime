function ds = cell2mat(ds, varargin)
% Convert numeric columns of the same sizes into matrix.

fs = ds.Properties.VarNames;
for f = fs(:)'
    v = ds.(f{1});
    if ~iscell(v) || isempty(v)
        continue;
    end
    if all(cellfun(@isnumeric, v)) && isrow(v{1})
        siz = size(v{1});
        if all(cellfun(@(vv) isequal(size(vv), siz), v))
            ds.(f{1}) = cell2mat(v);
        end
    end
end
end