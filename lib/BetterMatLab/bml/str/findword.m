function loc = findword(text, word)
% Find a word that is surrounded by non-alphanumeric, non-underscores.
% loc = findword(text, word)
%
% word can be a cell array of strings, in which case loc is also a cell array.
%
% EXAMPLE:
% >> loc = findword('abc+def, abcd, [abc], abc abc', {'abc', 'def', 'ghi'}); loc{:}
% ans =     1    17    23    27
% ans =     5
% ans =   Empty matrix: 1-by-0
%
% See also: regexp

if iscell(word)
    loc = cellfun(@(w) findword(text, w), word, 'UniformOutput', false);
    return;
end

text = [' ' text ' '];

len = length(word);
st  = strfind(text, word);
en  = st + len - 1;
n   = length(st);

bef = text(st - 1);
aft = text(en + 1);

bef_space = false(1, n);
aft_space = false(1, n);

bef_space(regexp(bef, '\W')) = true;
aft_space(regexp(aft, '\W')) = true;

loc = st(bef_space & aft_space) - 1;