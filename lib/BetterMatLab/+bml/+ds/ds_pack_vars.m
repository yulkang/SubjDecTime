function varargout = ds_pack_vars(varargin)
% DS_PACK_VARS  Set dataset values using workspace variable name & values.
%
% ds = ds_pack_vars(ds, ix, varargin)
%
% See also ds_set
[varargout{1:nargout}] = ds_pack_vars(varargin{:});