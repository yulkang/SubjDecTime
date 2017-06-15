function varargout = funPrintfChop(varargin)
% Chop at connectChar, except when it's preceded by %.
%
% c = funPrintfChop(frm, connectChar)
[varargout{1:nargout}] = funPrintfChop(varargin{:});