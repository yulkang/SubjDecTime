function varargout = ds_file_fun(varargin)
% DS_FILE_FUN - Perform multiple operations for files and rows and save to field.
%
% [ds, succ, any_op, L_out] = file_fun_ds(ds, files, op1, op2, ..., 'opt1', opt1, ...)
%
% op 
% : {cond, {vars}, fun(row, L, ix, [ds]), out_field, [op_opt]}
%
% cond
% : a logical scalar or vector (same length as files), indicating
%   whether to perform the given operation for the corresponding file.
%
% vars 
% : Give ':' to load all. Otherwise, give a cell array of var names.
%
% fun(row, L, ix, [ds]) 
% : row is a row in the dataset that corresponds to the file.
%   L is a struct that contains vars loaded from the file.
%   ix is the index of the row in the dataset.
%   ds is the whole dataset. Set give_ds = true to use.
%
% out_field
% : Field(s) of the ds to save the result from fun().
%   In case out_field is a cell array, fun() should have matching
%   number of outputs.
%
% op_opt
% : name-value pairs of options specific to the operation.
%
% 'give_ds'
% : Gives the whole dataset, ds, to fun. Can slow down the operation.
%   Defaults to false.
%
% opt
% : name-value pairs.
%
% 'parallel'
% : If true, uses parfor. Defaults to false.
[varargout{1:nargout}] = ds_file_fun(varargin{:});