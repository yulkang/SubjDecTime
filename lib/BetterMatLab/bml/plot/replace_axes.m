function new_ax = replace_axes(dst, src)
% new_ax = replace_axes(dst, src)
pos = get(dst, 'Position');
parent = get(dst, 'Parent');

new_ax = copyobj(src, parent);
set(new_ax, 'Position', pos);
delete(dst);