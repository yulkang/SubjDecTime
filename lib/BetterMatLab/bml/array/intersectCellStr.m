function tf_a = intersectCellStr(a, b)
% intersectCellStr  Fast intersect operation for small-sized cell arrays of strings.
%
% tf_a = intersectCellStr(a, b)
%
% tf_a is a logical array of the same size as a.
%
% Whenever possible, give smaller cell arrays to b.
%
% For large-sized (>300) cell arrays, use intersect_cellstr, which is slower for
% small-sized cell arrays.

tf_a = false(size(a));

for cb = b
    tf_a = tf_a | strcmp(cb{1}, a);
end
end