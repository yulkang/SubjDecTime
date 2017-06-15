function [class, pkg] = pkg2class(full_class)
% [class, pkg] = pkg2class(full_class)
assert(ischar(full_class));
ix = find(full_class == '.', 1, 'last');
if isempty(ix)
    class = full_class;
    pkg = '';
else
    class = full_class((ix+1):end);
    pkg = full_class(1:(ix-1));
end