function varargout = fminconMult(varargin)
% res = fminconMult(fun, params, opt)
%
% fun      : will be fed to fminconWrap.
% params   : nParam x (name, guesses, min, max) cell array.
% guesses  : numerical vector.
% min, max : scalar.
% opt      : as defined by optimset.
%
% res      : a struct.
%
% See also: FMINCONWRAP, FMINCON.
[varargout{1:nargout}] = fminconMult(varargin{:});