function varargout = fmin_iter(varargin)
% FMIN_ITER  iterative fitting of functions
%
% ds = fmin_iter(fun_sets, x, varargin)
%
% INPUTS:
% -------
% fun_sets:
%   {@fun1, {opt1}, [@fun2, {opt2} ...]}
%
% @fun: 
%     [x, fval, exitflag, output, lambda, grad, hessian] = f(x0, opt)
%
%     INPUT:
%         x0 : current guess
%         opt: output of optimset().
%     OUTUT:
%         x     : updated guess
%         fval  : cost
%         exitflag : 0 when number of iterations is exceeded.
%         lambda, grad, hessian: see help fmincon.
%
% {opt}:
%     Input to optimset(). Leave empty to use defaults.
%
% OUTPUTS:
% --------
% ds: A dataset with results from @fun as columns.
[varargout{1:nargout}] = fmin_iter(varargin{:});