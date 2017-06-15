function tf_a = intersect_cellstr(a, b)
tf_a = cellfun(@(s) any(strcmp(s, b)), a);
end