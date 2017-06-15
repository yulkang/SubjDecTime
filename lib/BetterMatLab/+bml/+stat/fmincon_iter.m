function varargout = fmincon_iter(varargin)
% FMINCON_ITER  Iterative fitting of parameters using fmincon.
%
% INPUTS
% ======
%
% [..] = fmincon_iter(arg_ord, opt_steps, opts, fun, x0, A, b, [Aeq, beq, lb, ub, nonlcon, options])
%
% arg_ord
%   : A matrix. arg_ord(k,l) == 0 means l-th parameter is fixed on k-th
%   step, and vice versa.
%   Every time after finishing all rows, a fitting with all parameters 
%   free will take place. So you don't need to add a row of all 1s.
%
% opt_steps
%   : {{opt_step_1}, {opt_step_2}, ...}
%   opt_steps{k} is a cell vector of name-value pairs that replaces the
%   default options for fmincon for k-th step.
%   length(opt_steps) == size(arg_ord,1) or size(arg_ord,1) + 1.
%   When it is the latter, it is for the full fitting at the end of each
%   turn.
%   Give {} to use defaults for all steps.
%
% opts
%   : Cell vector of name-value pairs of other options specific to fmincon_iter.
%
% The rest of the arguments are directly fed to fmincon(). They are:
% x0, A, b, Aeq, beq, lb, ub, nonlcon, options.
%
% Precedance of options
% ---------------------
% Overlapping options will be overwritten in the following order:
%
%   options (fmincon argument) < opt_steps
%
% OUTPUTS
% =======
% Outputs are the same as fmincon evaluated with all parameters enabled
% at the conclusion of the iteration. Users can also get the full history.
%
% [x,fval,exitflag,output,lambda,grad,hessian,history] = fmincon_iter(..)
%
% history
%   : A struct array that has each iteration's full outputs as fields.
%
% USAGE NOTE
% ==========
% When a problem can be separated into several independent subproblems,
% it may be much faster to solve each subproblem in turn. Especially,
% when the cost function takes very long time to evaluate (e.g., PDE),
% and the gradient function is not directly given, the finite gradient
% estimation can take up very long time. Save the evaluation of cost 
% function by making (a portion of) it return the same value as returned 
% from the previous call when certain paramters are the same.
%
% See also: fmincon, optimset
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = fmincon_iter(varargin{:});