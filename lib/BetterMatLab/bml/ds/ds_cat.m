function ds1 = ds_cat(ds1, ds2)
% DS_CAT - Vertically concatenate one dataset to another.
%          Also pools variable names as needed.
%
% ds1 = ds_join(ds1, ds2)
%
% See also: dataset

len1 = length(ds1);
len2 = length(ds2);

% col1 = ds1.Properties.VarNames;
% col2 = ds2.Properties.VarNames;

% cols = union(col1, col2, 'stable');

ds1 = ds_set(ds1, (len1+1):(len1+len2), ds2);