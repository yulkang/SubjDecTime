function varargout = fminconWrap(varargin)
% varargout = fminconWrap(fun, paramGuess, paramMin, paramMax, opt)
%
% See also FMINCON, FMINCONMULT.
[varargout{1:nargout}] = fminconWrap(varargin{:});