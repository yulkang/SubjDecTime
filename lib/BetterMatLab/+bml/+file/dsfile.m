function varargout = dsfile(varargin)
% ds = dsfile(op, file, in, varargin)
%
% % Append rows.
% ds = dsfile('add', file, STRUCT_OR_NAME_VALUE_PAIR) 
%
% % Modify arbitrary rows. See DS_SETS for details.
% ds = dsfile('set', file, {INPUT_FOR_ds_setS})    
%
% % Read arbitrary rows. Omit index to read all.
% % readS: read into a struct.
% % read : read into a dataset.
% ds = dsfile('readS', file, [index])      
%
% index: index or function handle that gets ds.
%
% 2014-2015 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = dsfile(varargin{:});