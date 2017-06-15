function varargout = fmincon_wrap(fun, paramGuess, paramMin, paramMax, opt)
% varargout = fmincon_wrap(fun, paramGuess, paramMin, paramMax, opt)
%
% See also FMINCON, FMINCONMULT.

p = length(paramGuess);

b = [vVec(paramMax); vVec(-paramMin)];
A = [eye(p); -eye(p)];

[varargout{1:nargout}] = fmincon(fun, paramGuess, A, b, [], [], [], [], [], opt);

end