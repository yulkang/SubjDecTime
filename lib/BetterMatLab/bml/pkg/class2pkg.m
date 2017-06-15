function pkg = class2pkg(cl)
% pkg = class2pkg(cl)

ix = find(cl == '.', 1, 'last');
if isempty(ix)
    pkg = '';
else
    pkg = cl(1:(ix-1));
end