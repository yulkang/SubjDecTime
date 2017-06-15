function s = funPrintfConnect(frm, connectChar, varargin)
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

c = funPrintfChop(frm, connectChar);

for ii = 1:length(c)
    c{ii} = funPrintf(c{ii}, varargin{:});
end

s = funPrintfBridge(connectChar, c{:});