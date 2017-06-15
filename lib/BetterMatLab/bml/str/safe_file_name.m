function s = safe_file_name(s, short_form)
% s = safe_file_name(s, short_form = false)

if nargin < 2, short_form = false; end

if short_form
    ix = bsxEq(s(:), '/?<>\:*|"^''');
    s(ix) = '_';
    
else
    s = strrep(s, '/', '_RD_');
    s = strrep(s, '?', '_QU_');
    s = strrep(s, '<', '_LB_');
    s = strrep(s, '>', '_RB_');
    s = strrep(s, '\', '_LD_');
    s = strrep(s, ':', '_CO_');
    s = strrep(s, '*', '_AS_');
    s = strrep(s, '|', '_OR_');
    s = strrep(s, '"', '_DQ_');
    s = strrep(s, '^', '_HT_');
    s = strrep(s, '''', '_SQ_');
end