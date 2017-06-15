function varargout = ds_filt(varargin)
% Gives ds(filt, fields) or ds(filt(ds), fields)
%
% ds = ds_filt(ds, filt, fields=':')
[varargout{1:nargout}] = ds_filt(varargin{:});