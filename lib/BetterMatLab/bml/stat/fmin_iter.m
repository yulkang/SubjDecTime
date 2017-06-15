function ds = fmin_iter(fun_sets, varargin)
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

%% Parse options
S = varargin2S(varargin, { ...
    'fit_fun',  @fmincon_wrap, ...
    'n_iter',   100, ...
    'optim_opt', {}, ...
    });

optim_opt = varargin2C(S.optim_opt, { ...
    'MaxIter',  5, ... % Small number to allow iteration
    });

%% Parse function sets
n_fun_set          = length(fun_sets) / 2;
fun_set(n_fun_set) = struct('fun', [], 'opt', {{}});
for i_fun = 1:n_fun_set
    fun_set(i_fun).fun = fun_sets{i_fun * 2 - 1};
    
    c_optim_opt        = varargin2C(fun_sets{i_fun * 2}, optim_opt);
    fun_set(i_fun).opt = optimset(c_optim_opt{:});
    
    % Empty fun_sets after use to save memory.
    fun_sets(i_fun * 2 + [-1, 0]) = {[], []};
end

%% Initialize for iterations
i_res   = 0;
ds      = dataset;

%% Iterate
for i_iter = 1:S.n_iter
    for i_fun = 1:n_fun_set
        i_res = i_res + 1;
        
        % Fit
        [x, fval, exitflag, output, lambda, grad, hessian] = ...
            fun_set(i_fun).fun(x, fun_set(i_fun).opt);

        % Save results
        ds = ds_pack_var(ds, i_res, i_iter, i_fun, ...
            x, fval, exitflag, output, lambda, grad, hessian);
        
        if exitflag ~= 0 % If it is not that number of iterations is exceeded
            break;
        end
    end
    
    if exitflag ~= 0
        break;
    end
end

ds = ds(1:i_res, :);