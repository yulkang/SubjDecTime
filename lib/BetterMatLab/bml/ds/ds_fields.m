function res = ds_fields(ds, ix, fields)
% res = ds_fields(ds, ix)           
% res = ds_fields(ds, ix, ':')      
% : both returns all fields. 
%
% res = ds_fields(ds, ix, 'field1') 
% : res is not a ds, unlike others, but just the field.
%
% res = ds_fields(ds, ix, {'field1', 'field2'}) % res is a ds with specified fields.

if ~exist('fields', 'var') || isequal(fields, ':')
    res = ds(ix, :);
    
elseif ischar(fields)
    res = ds.(fields)(ix,:);
    
elseif iscell(fields)
    res = ds(ix,fields);
    
else
    error('fields should be a string, a cell of strings, or omitted!');
end