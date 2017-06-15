function varargout = ds_setS(varargin)
% ds = ds_setS(ds, ix, v, varargin)
%
% ix: logical or numeric index or a function handle that gets ds.
% v: either a struct or a cell array of name-value pairs.
%
% OPTIONS
% -------
% 'existing2cell',true % Enforce existing non-cell columns into a cell, as needed
% 'scalar2cell',  true % Sets everything in a cell, except a cell column vector if cell2cell is false.
% 'cell2cell',    false % Sets everything in a cell, even a cell.
% 'struct2cell',  true
% 'object2cell',  true
% 'mat2cell',     true
% 'char2cell',    true
% 'unpackFields', true
% 'unpackFieldsArg', {}
% 
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = ds_setS(varargin{:});