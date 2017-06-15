function varargout = cellfprintf(varargin)
% str = cellfprintf(varargin)
%
% Same as cellprintf, but also prints to prompt.
[varargout{1:nargout}] = cellfprintf(varargin{:});