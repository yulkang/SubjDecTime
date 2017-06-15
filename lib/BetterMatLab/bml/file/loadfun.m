function d = loadfun(file, fun)
% d = loadfun(file, fun)
m = matfile(file);
d = fun(m);