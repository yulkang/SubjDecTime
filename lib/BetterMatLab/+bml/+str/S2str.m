function varargout = S2str(varargin)
% Convert a non-nested struct to string efficiently
[varargout{1:nargout}] = S2str(varargin{:});