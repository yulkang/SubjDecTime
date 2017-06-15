function dst = filenamefun(fun, src)
% dst = filenamefun(fun, src)
%
% dst = fun(src_path, src_name, src_ext)
% src_path = {'dir1', 'dir2', ...}
% dst = {dst_path, dst_name, dst_ext}
% 
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

assert(isa(fun, 'function_handle'));
if iscell(src)
    dst = cellfun(@(s) filenamefun(fun, s), src, 'UniformOutput', false);
    return;
else
    assert(ischar(src));
end

[pth, nam, ext] = filepartsCell(src);
C_dst = fun(pth, nam, ext);
dst = fullfile(C_dst{1}{:}, [C_dst{2}, C_dst{3}]);
end