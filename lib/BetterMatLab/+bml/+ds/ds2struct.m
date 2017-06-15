function varargout = ds2struct(varargin)
% ds2struct  Convert dataset, object, or struct into a struct.
%
% S = ds2struct(S)
%
% See also: dataset, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.
[varargout{1:nargout}] = ds2struct(varargin{:});