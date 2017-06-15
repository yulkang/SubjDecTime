function varargout = ds_fields(varargin)
% res = ds_fields(ds, ix)           
% res = ds_fields(ds, ix, ':')      
% : both returns all fields. 
%
% res = ds_fields(ds, ix, 'field1') 
% : res is not a ds, unlike others, but just the field.
%
% res = ds_fields(ds, ix, {'field1', 'field2'}) % res is a ds with specified fields.
[varargout{1:nargout}] = ds_fields(varargin{:});