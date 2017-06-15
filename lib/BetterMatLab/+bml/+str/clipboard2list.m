function C = clipboard2list(s0)
% C = clipboard2list(s0='pasted_from_clipboard')
%
% Chops string into a cell vector at newlines.
%
% 2016 Yul Kang. hk2699 at columbia dot edu.

if ~exist('s0', 'var')
    s0 = clipboard('paste');
end
C = vVec(strsep2C(s0, sprintf('\n')));
if nargout == 0
    s = sprintf('''%s''\n', C{:});
    s = sprintf('{\n%s}', s);
    clipboard('copy', s);
end
end