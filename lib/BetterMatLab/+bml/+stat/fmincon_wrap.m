function varargout = fmincon_wrap(varargin)
% varargout = fmincon_wrap(fun, paramGuess, paramMin, paramMax, opt)
%
% See also FMINCON, FMINCONMULT.
[varargout{1:nargout}] = fmincon_wrap(varargin{:});