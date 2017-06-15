function tf = iscolumn_ds(ds, f)
% tf = iscolumn_ds(ds, f)

tf = any(strcmp(f, ds.Properties.VarNames));