function ds = ds_rmfield(ds, field)
% ds = ds_rmfield(ds, field)

if iscell(field)
    for ii = 1:numel(field)
        ds.(field{ii}) = [];
    end
else
    assert(ischar(field));
    ds.(feild) = [];
end
end