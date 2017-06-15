function varargout = dirfiles(varargin)
% Full path to files (not folders) within the given folder.
%
% [F, N] = dirfiles(D)
%
% D: Path to a folder.
% F: Cell array of full paths.
% N: Cell array of file names.
[varargout{1:nargout}] = dirfiles(varargin{:});