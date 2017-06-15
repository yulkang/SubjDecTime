function help_class(obj, meth)
% help_class(obj, meth)
if exist('meth', 'var') && ~isempty(meth)
    help([class(obj) '.' meth]);
else
    help(class(obj));
end
