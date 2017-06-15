function varargout = cell2cellincell(varargin)
% Make {e11, e12, ...; ...} into {{e11, e12, ...}, {...}, ...} format.
%
% c = cell2cellincell(c)
[varargout{1:nargout}] = cell2cellincell(varargin{:});