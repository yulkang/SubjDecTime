function varargout = invLogit(varargin)
% p = invLogit(x)
%   = exp(x)/(1+exp(x));
[varargout{1:nargout}] = invLogit(varargin{:});