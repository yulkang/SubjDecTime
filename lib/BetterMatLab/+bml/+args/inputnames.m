function varargout = inputnames(varargin)
% nam = inputnames
% nam = inputnames(ix)
% nam = inputnames('varargin')
[varargout{1:nargout}] = inputnames(varargin{:});