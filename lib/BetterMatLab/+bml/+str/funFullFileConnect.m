function varargout = funFullFileConnect(varargin)
% Same as funFullFile but connects within components
% with connectChar only when nonempty.
%
% EXAMPLE:
% >> funFullFileConnect('a_b/c_d', '_', 'c', 'CC')
% ans = a_b/CC_d
% 
% >> funFullFileConnect('a_b/c_d', '_', 'c', 'CC', 'a', '', 'b', '', 'd', '')
% ans = CC
%
% res = funFullFileConnect(frm, connectChar, varargin)
%
% See also funPrintfConnect
[varargout{1:nargout}] = funFullFileConnect(varargin{:});