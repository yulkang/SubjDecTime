function varargout = filewrite(varargin)
% filewrite(file, text)
%
% If text is a cell array, each cell becomes a line.
%
% See also: fileread
[varargout{1:nargout}] = filewrite(varargin{:});