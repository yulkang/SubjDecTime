function varargout = copyfile2(varargin)
% Same as copyfile except this creates destination folder if absent
%
% copyfile2(src, dst, verbose = false, ...)
[varargout{1:nargout}] = copyfile2(varargin{:});