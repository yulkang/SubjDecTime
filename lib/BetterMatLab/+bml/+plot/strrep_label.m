function str = strrep_label(str)
str = strrep_cell(str, {
    '_', '\_'
    '^', '\^'
    '{', '\{'
    '}', '\}'
    }, [], 'wholeStringOnly', false);
end