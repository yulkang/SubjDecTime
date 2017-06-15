function tf = dsIsCol(ds, col)
% tf = dsIsCol(ds, col)

tf = any(strcmp(col, ds.Properties.VarNames));