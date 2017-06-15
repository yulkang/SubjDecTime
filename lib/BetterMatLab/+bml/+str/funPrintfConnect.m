function varargout = funPrintfConnect(varargin)
% Same as funPrintf but connects with connectChar only when nonempty.
%
% s = funPrintfConnect(frm, connectChar, varargin)
%
% EXAMPLE:
%
% >> funPrintfConnect('a_b', '_', 'b', 'CC')
% ans = a_CC
% 
% >> funPrintfConnect('a_b', '_', 'b', '')
% ans = a
%
% See also funFullFileConnect
[varargout{1:nargout}] = funPrintfConnect(varargin{:});