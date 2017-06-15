function d = class2dir(cl)
% d = class2dir(cl)
%
% EXAMPLE
% -------
% >> class2dir('a.b.c')
% ans =
% +a/+b/c
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

[cl, pkg] = pkg2class(cl);
d = fullfile(pkg2dir(pkg), cl);