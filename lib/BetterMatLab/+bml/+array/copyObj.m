function varargout = copyObj(varargin)
% Copy an object (array) to a new one.
% Especially useful when copying a handle object (array).
[varargout{1:nargout}] = copyObj(varargin{:});