function varargout = cell2varargout(varargin)
% varargout = cell2varargout(C, n_out = nargout)
[varargout{1:nargout}] = cell2varargout(varargin{:});