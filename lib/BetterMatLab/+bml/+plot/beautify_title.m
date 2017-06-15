function str = beautify_title(str)
% str = beautify_title(str0)
str = bml.str.wrap_text(bml.plot.strrep_label(str));
end