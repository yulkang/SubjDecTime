function tf = ds_isfield(ds, f)
% DS_ISFIELD  isfield for datasets. 
%
% tf = ds_isfield(ds, field_name)

tf = any(strcmp(f, ds.Properties.VarNames));