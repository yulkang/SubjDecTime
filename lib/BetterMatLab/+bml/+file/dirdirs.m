function varargout = dirdirs(varargin)
% Directories within the given folder.
%
% [F, N] = dirfiles(D)
%
% D: Path to a folder.
% F: Cell array of full paths.
% N: Cell array of directory names.
[varargout{1:nargout}] = dirdirs(varargin{:});