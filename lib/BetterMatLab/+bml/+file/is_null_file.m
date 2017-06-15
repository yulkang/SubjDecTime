function tf = is_null_file(file)
% See also: save_null
info = dir(file);
tf = (info.bytes == 0) && (info.isdir == 0);