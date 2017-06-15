function varargout = ds_set(varargin)
% Assign data to columns. Convenient when adding column or using scalar value.
% 
% ds = ds_set(ds, ix, 'col1', val1, 'col2', val2, ...)
% ds = ds_set(ds, ix, dataset_or_struct)
% ds = ds_set(ds, ix, dataset_or_struct, 'only', {'col1', 'col2', ...})
% ds = ds_set(ds, ix, dataset_or_struct, 'except', {'col1', 'col2', ...})
% ds = ds_set(ds, ix, cell_array_of_columns) % Fill from the first columns
% ds = ds_set(ds, ix, cell_array_of_columns, 'only', logical_ix) % Fill designated columns
% ds = ds_set(ds, ix, cell_array_of_columns, 'only', numerical_ix)
% ds = ds_set(ds, ix, cell_array_of_columns, 'only', {'col1', 'col2', ...}) % One can augment columns by giving new column names
% [ds, added_cols] = ds_set(...)
%
% ix: logical or numerical index for the row(s), or a function handle.
% added_cols: Columns that did not exist before adding.
%
% If values for a column have variable lengths, give a cell array.
%
% EXAMPLE:
% >> ds = dataset;
% >> ds.rep = {'aa', 'bb', 'aa'}'
% ds = 
%     rep     
%     'aa'    
%     'bb'    
%     'aa'    
% 
% >> ds = ds_set(ds, ':', 'succT', false)
% ds = 
%     rep         succT
%     'aa'        false
%     'bb'        false
%     'aa'        false
%
% >> ds = ds_set(ds, 2:3, 'str', {'abc', 'd'})
% ds = 
%     rep         succT         str
%     'aa'        false         []
%     'bb'        false         'abc'
%     'aa'        false         'd'
%
% See also: dsSet, ds_pack_vars
[varargout{1:nargout}] = ds_set(varargin{:});