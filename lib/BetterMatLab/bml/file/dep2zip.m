function varargout = dep2zip(filename, varargin)
% DEP2ZIP Zips all files that depend on the .m file.
%
% [...] = dep2zip(m_file_name, ...)
%
% See also DEP2TXT

[varargout{1:nargout}] = dep2txt(filename, 'zipFile', [filename '.zip'], varargin{:});