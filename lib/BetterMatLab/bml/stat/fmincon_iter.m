function varargout = fmincon_iter(arg_ord, opt_steps, opts, fun, x0, varargin)
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

%% Inputs
% Options
opts = varargin2C( opts, {...
    });

try
    fmincon_opt_common_C = varargin{8};
    
    if isempty(fmincon_opt_common_C), fmincon_opt_common_C = {}; end % [] causes an error.
catch
    fmincon_opt_common_C = {};
end

fmincon_opt_common_C = varargin2C(fmincon_opt_common_C, { ...
    'MaxIter',      5, ...
    'UseParallel',  'always', ...
    });

fmincon_opt_common = optimset(fmincon_opt_common_C{:});

n_param = size(arg_ord, 2);
n_step  = size(arg_ord, 1);
arg_ord = [logical(arg_ord); true(1, n_param)];

if ~isempty(opt_steps)
    assert(iscell(opt_steps) ...
        && (length(opt_steps) == n_step || length(opt_steps) == (n_step + 1)) ...
        && all(cellfun(@iscell, opt_steps)), ...
        ['opt_steps should be empty or have the same number of elements as ' ...
         'the number of rows in arg_ord, which is the number of steps!']);

    if length(opt_steps) == n_step + 1
        fmincon_opt(n_step + 1) = optimset(fmincon_opt_common, ...
            opt_steps{n_step + 1}{:});
    else
        fmincon_opt(n_step + 1) = fmincon_opt_common;
    end
    
    for i_step = n_step:-1:1
        fmincon_opt(i_step) = optimset(fmincon_opt_common, ...
            opt_steps{i_step}{:});
    end    
else
    for i_step = (n_step + 1):-1:1
        fmincon_opt(i_step) = fmincon_opt_common;
    end
end

% Keep the length of varargin to 7, leaving room for fmincon_opt.
if length(varargin) >= 7
    varargin = varargin(1:7);
else
    varargin{7} = [];
end

% Misc.
remember_history = (nargout >= 8);

%% Iterative fitting
% Initialize
c_x     = x0;
i_iter  = 0;
to_exit = false;

output_names = {'x', 'fval', 'exitflag', 'output', 'lambda', 'grad', 'hessian'};
nargout_fmincon = max(min(nargout, length(output_names)), 1);
outputs = cell(1, nargout_fmincon);

ix_lb   = 5;
ix_ub   = 6;

% Loop
while ~to_exit
    % Index
    i_iter = i_iter + 1;
    
    for c_step = 1:(n_step + 1)

        % Fix a subset of parameters
        to_fix = ~arg_ord(c_step, :);
        
        c_argin = varargin;
        if isempty(c_argin(ix_lb))
            c_argin{ix_lb} = -inf(1, n_param);
            c_argin{ix_lb}(to_fix) = c_x(to_fix);
        else
            c_argin{ix_lb}(to_fix) = c_x(to_fix);
        end

        if isempty(c_argin(ix_ub))
            c_argin{ix_ub} = inf(1, n_param);
            c_argin{ix_ub}(to_fix) = c_x(to_fix);
        else
            c_argin{ix_ub}(to_fix) = c_x(to_fix);
        end

        % Fit
        [c_x, c_fval, c_exitflag, outputs{4:nargout_fmincon}] = ...
            fmincon(fun, c_x, c_argin{:}, fmincon_opt(c_step));
        outputs(1:3) = {c_x, c_fval, c_exitflag};

        % Save history in column major order.
        if remember_history
            history(c_step, i_iter) = cell2struct(outputs, output_names(1:nargout_fmincon), 2); %#ok<AGROW>
        end        
    end
    
    % Exit iteration depending on the result of full fitting
    to_exit = (c_exitflag ~= 0);
end

%% Output
varargout(1:nargout_fmincon) = outputs(1:nargout_fmincon);

if nargout >= 8
    varargout{8} = history;
end
end