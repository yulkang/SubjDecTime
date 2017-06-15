function varargout = funPrintfBridge(varargin)
% FUNPRINTFBRIDGE - Bridge strings with connectChar except when it's empty
% : Replaced with str_bridge. See str_bridge.
%
% See also: str_bridge, str, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

[varargout{1:nargout}] = str_bridge(varargin{:});