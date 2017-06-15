function varargout = baseCallerParts(varargin)
% Same as fileparts but returns name with package qualifiers.
[varargout{1:nargout}] = baseCallerParts(varargin{:});