function [tf, a] = setdiff_cellstr(a, b)
% tf = setdiff_cellstr(a, b)
tf = ~cellfun(@(s) any(strcmp(s, b)), a);

if nargout >= 2
    a = a(tf);
end
end