function varargout = ds_cat(varargin)
% DS_CAT - Vertically concatenate one dataset to another.
%          Also pools variable names as needed.
%
% ds1 = ds_join(ds1, ds2)
%
% See also: dataset
[varargout{1:nargout}] = ds_cat(varargin{:});