function res = funFullFileConnect(frm, connectChar, varargin)
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

src = funPrintfChop(frm, '/');

for ii = 1:length(src)
    src{ii} = funPrintfConnect(src{ii}, connectChar, varargin{:});
end

res = fullfile(src{:});