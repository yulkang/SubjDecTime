function varargout = fminconMultOld(varargin)
% S  = fminconWrap(fun, data, opt, paramName1, paramGuess1, paramMin1, paramMax1, ...)
%
% Try multiple guesses
[varargout{1:nargout}] = fminconMultOld(varargin{:});