function C = line2cell(str)
% line2cell  Returns a cell array of strings in each line given a string vector.
%
% C = line2cell(str)
%
% Line breaks are at \r and \n.  Result strings don't include \r or \n.
% A pair of non-identical consecutive line breakers are treated as one.
% If there is a line breaker in the beginning or at the end, an empty
% string is added.
%
% EXAMPLE:
% >> line2cell(sprintf('abc\ndef'))
% ans = 
%     'abc'    'def'
% 
% >> line2cell(sprintf('abc\n\rdef'))
% ans = 
%     'abc'    'def'
% 
% >> line2cell(sprintf('abc\r\ndef'))
% ans = 
%     'abc'    'def'
% 
% >> line2cell(sprintf('abc\r\rdef'))
% ans = 
%     'abc'    [1x0 char]    'def'
% 
% >> line2cell(sprintf('\r\nabc\rdef\r\n'))
% ans = 
%     [1x0 char]    'abc'    'def'    [1x0 char]
%
% See also: str, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

line_end_chars = sprintf('\n\r');

is_line_end_orig = bsxFind(str(:), line_end_chars)';

[is_line_end, chng] = remove_duplet([0, is_line_end_orig]);
while any(chng)
    [is_line_end, chng] = remove_duplet(is_line_end);
end

ix_line_end = [0, find(is_line_end(2:end)), length(str)+1];

n = length(ix_line_end) - 1;

C = cell(1, n);
siz = size(str);

for ii = 1:n
    C{ii} = str( ...
        ~is_line_end_orig & ...
        ix2tf(siz, (ix_line_end(ii) + 1):(ix_line_end(ii + 1) - 1)));
end
end


function [str, chng] = remove_duplet(str)

ix = [strfind(str, [0 1 2]), strfind(str, [0 2 1])];

if isempty(ix)
    chng = false;
else
    chng = true;
    str(ix+2) = 0;
end
end
