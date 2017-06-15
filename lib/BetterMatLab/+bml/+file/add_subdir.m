function file = add_subdir(file, subdir)
% file = add_subdir(file, subdir)
[pth, nam, ext] = fileparts(file);
file = fullfile(pth, subdir, [nam, ext]);