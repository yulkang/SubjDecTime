function ds = permute(ds0)
% ds = permute(ds0)

C = dataset2cell(ds0);
ds = cell2dataset(C', 'ReadObsNames', true, 'ReadVarNames', true);