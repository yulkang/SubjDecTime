function varargout = filenamefun(varargin)
% dst = filenamefun(fun, src)
%
% dst = fun(src_path, src_name, src_ext)
% src_path = {'dir1', 'dir2', ...}
% dst = {dst_path, dst_name, dst_ext}
% 
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = filenamefun(varargin{:});