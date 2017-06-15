function varargout = isNameValuePair(varargin)
% isNameValuePair  Examines if the argument is in the format of {'name1', value1, ...}
%
% See also: varargin2S, varargin2V, arg, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.
[varargout{1:nargout}] = isNameValuePair(varargin{:});