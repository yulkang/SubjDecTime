classdef Fit_flow < matlab.mixin.Copyable
    
properties
    th = struct;
    th_0 = struct;
    th_ub = struct;
    th_lb = struct;
    
    dat = dataset;
    
    S = struct; % struct of intermediate variables.
    c = 0; % a scalar double produced by f_costs.
    res = struct; % struct containing last fit results.
    
    modules = {};
    module_names = {};
    
    f_init_S = struct; % Functions called once before iteration begins.
    f_pred_S = struct; % Functions called on every loop for prediction.
    f_cost_S = struct; % Functions called on every loop for calculating cost.
    
    f_inits = {}; % init function names in the order of calls.
    f_preds = {}; % pred function names in the order of calls.
    f_costs = {}; % cost function names in the order of calls.
    
    running_kind = '';
    running_fun  = '';
    
    nargin_inits = [];
    nargin_preds = [];
    nargin_costs = [];
    
    init_called = false;
    catch_error = false;
end

properties (Dependent)
    n_module
    n_th        % Number of parameters.
    
    dat_names   % A row cell vector of data column names.
    th_names    % A row cell vector of parameter names.
    th_vec      % A row vector of scalar parameters in the order of th_names.
    th_0_vec    % A row vector of initial guesses.
    th_ub_vec   % A row vector of upper bound of parameters.
    th_lb_vec   % A row vector of lower bound of parameters.
    
    dat_mat % A matrix with columns in the order of dat_names.
    
    modules_S % A struct with module names.
end

methods
function me = Fit_flow(fit_modules, varargin)
    % Fit_flow  Combines fit_module objects for fitting.
    %
    % obj = Fit_flow({fit_module1, fit_module2, ...}, ['prop_name1', prop_value1, ...])
    %
    % The order of modules matter. Most importantly, withiin each of
    % initialization, prediction, and cost calculation steps, 
    % modules are considered sequentially for their .init, .pred, and .cost
    % methods. In case one calculation depends on another (such as adding
    % bias/scale to another parameter), different order will give different
    % results.
    %
    % In case the order conflicts between modules and steps
    % (e.g., the order of 
    %   module1.init -> module2.init and 
    %   module2.pred -> module1.pred
    % are required simultaneously),
    % set obj.f_inits, obj.f_preds, and/or obj.f_costs manually 
    % in the correct order. They are just cell arrays that can be manipulated
    % in usual ways. One can add/remove/reorder functions to them,
    % as long as they obey the input/output restrictions given in 
    % the documentation of Fit_module/Fit_module.
    %
    % EXAMPLE:
    %
    % See also Fit_module
    %
    % 2014 (c) Yul Kang. hk2699 at columbia dot edu.
    
    if exist('fit_modules', 'var') && ~isempty(fit_modules)
        add_modules(me, fit_modules);
    end
    
    varargin2fields(me, varargin, false);
end

function add_modules(me, fit_modules)
    % add_modules(me, fit_modules)
    %
    % Note that, if you reordered f_inits/preds/costs, adding modules
    % may overwrite it in a wrong way. It is a better practice to 
    % reorder f_inits/preds/costs after you add all modules, if at all.
    %
    % See also Fit_flow.
    
    % Take a union of added modules and existing ones.
    if isstruct(fit_modules)
        new_module_names = fieldnames(fit_modules);
    elseif iscell(fit_modules)
        new_module_names = cellfun(@(c) c.tag, fit_modules, 'UniformOutput', false);
        fit_modules      = cell2struct(fit_modules(:)', new_module_names(:)', 2);
    else
        error('Fit_flow:modules_format', ...
            'modules should be a struct or a cell array!');
    end
    
    all_module_names = union(me.module_names, new_module_names, 'stable');
    [~, ix_new] = intersect(all_module_names, new_module_names, 'stable');
    ix_new = ix_new(:)';
    
    me.modules_S = copy_fields(me.modules_S, fit_modules, 'all');
    
    % For each updated module,
    for i_module = ix_new
        c_module = me.modules{i_module};
        
        % Merge th_names and dat_names.
        me.th_names  = union(me.th_names,  c_module.th_names,  'stable');
        me.dat_names = union(me.dat_names, c_module.dat_names, 'stable');
        
        % Set th_0, th_ub, and th_lb.
        for c_th = c_module.th_names(:)'
            for c_prop = {'th_0', 'th_lb', 'th_ub'}
                v = c_module.(c_prop{1}).(c_th{1});
                
                if ~isempty(v)
                    me.(c_prop{1}).(c_th{1}) = v;
                end
            end
        end
        
        % Set default f_inits/preds/costs.
        add_fun(me, 'init', str_con(c_module.tag, 'init'), @c_module.init);
        add_fun(me, 'pred', str_con(c_module.tag, 'pred'), @c_module.pred);
        add_fun(me, 'cost', str_con(c_module.tag, 'cost'), @c_module.cost);
    end
end

function add_fun(me, kind, fun_name, fun)
    % ADD_FUN  Add init, pred, or cost function to f_*_S and f_*s.
    %
    % add_fun(me, kind, fun_name, fun)
    
    assert(any(strcmp(kind, {'init', 'pred', 'cost'})), ...
        'Function kind should be either init, pred, or cost!');
    
    f_S = ['f_' kind '_S'];
    f_C = ['f_' kind 's'];
    
    if isfield(me.(f_S), fun_name)
        warning(['Existing function %s_S.%s is overwritten!\n' ...
                 'If you didn''t mean this, give each module a unique tag!'], ...
            f_S, fun_name);
    end
    
    me.(f_S).(fun_name) = fun;
    me.(f_C) = union(me.(f_C), fun_name, 'stable');
end

function init(me, c_dat, c_th_0)
    % init(me, [c_dat, c_th_0])
    %
    % c_dat  : A dataset, struct, or matrix.
    % c_th_0 : Current guess.
    
    % Initialize intermediate variables.
    me.S = struct;
    
    % Set data.
    if exist('c_dat', 'var') && ~isempty(c_dat)
        % Remember current name order.
        c_dat_names = me.dat_names;
        
        % Convert c_dat into a dataset.
        if isa(c_dat, 'dataset')
            me.dat = c_dat;
            
        elseif isstruct(c_dat)
            me.dat = ds_set(dataset, ':', c_dat);
            
        elseif isnumeric(c_dat) && ismatrix(c_dat)
            me.dat_mat = c_dat;
            
        else
            error('data should be a dataset, struct, or a numeric matrix!');
        end
        
        % Set order & remove extra columns.
        me.dat_names = c_dat_names; 
    end
    
    % Set parameters.
    if exist('c_th_0', 'var') && ~isempty(c_th_0)
        me.th_0_vec = c_th_0;
    end
    
    % Go through f_inits.
    if me.catch_error
        try
            call_f_inits;
        catch err
            report_f_error(me, err);
        end
    else
        call_f_inits;
    end
    
    % Set flag.
    me.running_kind = '';
    me.running_fun  = '';
    me.init_called = true;
    
    % Nested function
    function call_f_inits
        for i_fun = 1:length(me.f_inits)
            % Record which function is running. Good for debugging.
            me.running_kind = 'init';
            me.running_fun = me.f_inits{i_fun};

            % Run
            me.f_init_S.(me.f_inits{i_fun})(me);
        end
    end
end

function pred(me)
    % First copy fields of th into P.
    me.S = copyFields(me.S, me.th);
    
    % Go through f_preds.
    if me.catch_error
        try
            call_f_preds;
        catch err
            report_f_error(me, err);
        end
    else
        call_f_preds;
    end
    
    % Nested function
    function call_f_preds
        for i_fun = 1:length(me.f_preds)
            % Record which function is running. Good for debugging.
            me.running_kind = 'pred';
            me.running_fun = me.f_preds{i_fun};
            
            % Run
            me.f_pred_S.(me.f_preds{i_fun})(me);
        end
    end
end

function c_cost = cost(me, c_th_vec)
    % c_cost = me.cost(c_th_vec)
    
    % Initialize.
    if ~me.init_called
        error('Call init() before calculating cost!');
    end
    
    me.c = 0;
    
    % If c_th_vec is provided, set me.th, the struct with named fields.
    if exist('c_th_vec', 'var') && ~isempty(c_th_vec)
        me.th_vec = c_th_vec;
        
    % If provided as empty or NaN, set as th_0_vec.
    elseif isempty(me.th_vec) || any(isnan(me.th_vec))
        me.th_vec = me.th_0_vec;
        
    % If not provided, leave as it is.
    end
    
    % Make prediction.
    pred(me);
    
    % Calculate cost.
    if me.catch_error
        try
            call_f_costs;
        catch err
            report_f_error(me, err);
        end
    else
        call_f_costs;
    end
    
    % Output
    c_cost = me.c;
    
    % Nested function
    function call_f_costs
        for i_fun = 1:length(me.f_costs)
            % Record which function is running. Good for debugging.
            me.running_kind = 'cost';
            me.running_fun = me.f_inits{i_fun};
            
            % Run
            me.f_cost_S.(me.f_costs{i_fun})(me);
        end    
    end
end

function report_f_error(me, err)
    if strcmp(err.identifier, 'MATLAB:nonExistentField')
        fprintf('f_%s_S.%s requested a non-existent field!\n', ...
            me.running_kind, me.running_fun);
    end
    rethrow(err);
end

%% Wrappers for fitting functions
function copy_res(me)
    % Copy result to th.
    
    try
        me.th = me.res.th;
    catch
        me.th_vec = me.res.x;
    end
    me.c = me.res.fval;
    
    try
        me.S = me.res.S;
    catch
        warning('Failed to find res.S!');
    end
end

function [x, fval, exitflag, output, lambda, grad, hessian, cov, se] = ...
        fminsearchbnd(me, varargin)
    % Parse & save input
    [C, SS] = parse_fminsearchbnd_input(me, varargin);
    
    wrap_fit_input(me, 'fminsearchbnd',  ...
        'input', SS, ...           % Struct form
        'input_raw', varargin ... % Raw input
        );
    
    % Run fit
    x = fminsearchbnd(@me.cost, C{:});
%     [x, fval, exitflag, output] = fminsearchbnd(@me.cost, C{:});
    
    % Run fmincon at the end to determine se, etc.
    [~, SS_fmincon] = parse_fmincon_input(me, SS);
    SS_fmincon.x0 = x + sign(rand(size(x))-0.5) .* abs(x) / 100;
    SS_fmincon.opt.MaxIter = 30;
    
    [x, fval, exitflag, output, lambda, grad, hessian, cov, se] = fmincon( ...
        me, SS_fmincon);
    
    % Save output & intermediate variables
    wrap_fit_output(me, x, fval, exitflag, output, lambda, grad, hessian, cov, se);
end

function [x, fval, exitflag, output, lambda, grad, hessian, cov, se] = ...
        fmincon(me, varargin)
    % FMINCON  Wrapper for fmincon().
    %
    % [x,fval,exitflag,output,lambda,grad,hessian,cov,se] = me.fmincon( ...
    %    'param_name1', param1, ...);
    %
    % param: One of 'x0', 'A', 'B', 'Aeq', 'Beq', 'lb', 'ub', 'nonlcon', 'opt'.
    % See help fmincon for details.
    % Leave unspecified to use the default value from modules.
    % Note that the cost function is always the method Flow.cost().
    %
    % See also: fmincon
    
    % Parse & save input
    [C, SS] = me.parse_fmincon_input(varargin);
    
    wrap_fit_input(me, 'fmincon', ...
        'input', SS, ...           % Struct form
        'input_raw', varargin ... % Raw input
        );
    
    % Run fit
    [x, fval, exitflag, output, lambda, grad, hessian] = fmincon( ...
        @me.cost, C{:});

    cov = inv(hessian);
    se  = sqrt(diag(cov)');
    
    % Save output & intermediate variables
    wrap_fit_output(me, x, fval, exitflag, output, lambda, grad, hessian, cov, se);
end

function [x, fval, exitflag, output, lambda, grad, hessian, hist] = fmincon_iter(me, arg_ord_C, opt_steps, opts, varargin)
    % FMINCON_ITER  Wrapper for fmincon_iter().
    %
    % [x,fval,exitflag,output,lambda,grad,hessian,hist] = me.fmincon_iter( ...
    %    arg_ord_C, opt_steps, opts, ...
    %    ['param_fmincon_1_name', param_fmincon_1, ...]);
    %
    % arg_ord_C
    % : A cell vector of cell vectors containing parameter names 
    %   to let free on each step of iteration.
    %   i.e., arg_ord_C = {iter_1, iter_2, ...}
    %   where iter_k = {'param1', 'param2', ...}.
    %
    % opt_steps
    % : A cell vector of cell vectors containing options (name-value pairs)
    %   for each step of iteration. 
    %   i.e., iter_opts_C = {opt_step_1, opt_step_2, ...}
    %   where opt_step_k = {'option_name1', option_value1, ...}.
    %   Give {} to use defaults for all steps. See fmincon_iter for defaults.
    %
    % param_fmincon_k
    % : One of 'x0', 'A', 'B', 'Aeq', 'Beq', 'lb', 'ub', 'nonlcon', 'opt'.
    %   See help fmincon for details.
    %   Leave unspecified to use the default value from modules.
    %   Note that the cost function is always the method Flow.cost().
    %
    % See also: fmincon_iter, fmincon
    
    % Parse arg_ord_C.
    n_step  = length(arg_ord_C);
    arg_ord = false(n_step, me.n_th);
    
    for i_step = 1:n_step
        ord_step_C = arg_ord_C{i_step};
        
        for i_th = 1:length(ord_step_C)
            
            th_loc = find(strcmp(ord_step_C{i_th}, me.th_names));
            arg_ord(i_step, th_loc) = true;
        end
    end
    
    % Parse opt_steps and opts.
    if ~exist('opt_steps', 'var'), opt_steps = {}; end
    if ~exist('opts', 'var'),      opts = {}; end
    
    % Parse inputs for fmincon & save it.
    [C, SS] = me.parse_fmincon_input(varargin);
    
    SS = mergeStruct(SS, packStruct(arg_ord_C, opt_steps, opts));
    
    wrap_fit_input(me, 'fmincon_iter',  ...
        'input', SS, ... % Struct form
        'input_raw', [{arg_ord_C, opt_steps, opts}, varargin] ... % Raw input
        );
    
    % Output
    [x, fval, exitflag, output, lambda, grad, hessian, hist] = fmincon_iter(arg_ord, opt_steps, opts, @me.cost, C{:});
    
    % Save output & intermediate variables
    wrap_fit_output(me, x, fval, exitflag, output, lambda, grad, hessian, hist);
end

function [x, fval, exitflag, output, local_solutions] = globalsearch(me, varargin)
    % [x, fval, exitflag, output, local_solutions] = globalsearch(me, varargin)
    %
    % Adopted from Jian's Global Optimization Toolbox demo (dtb_demo.m)
    
    % Parse input
    opt = varargin2S(varargin, { ...
        'local_fun', @fmincon, ...
        'opt', {}, ...
        });
    
    if isstruct(opt.opt), opt.opt = S2C(opt.opt); end
    opt.opt = varargin2C(opt.opt, { ...
        'Algorithm',    'active-set', ...
        'FinDiffType',  'central', ...
        'UseParallel',  'always', ...
        });
    
    opt.opt = optimoptions(opt.local_fun, opt.opt{:});
    problem = createOptimProblem('fmincon', ...
        'x0',        me.th_0_vec, ...
        'objective', @me.cost, ...
        'lb',        me.th_lb_vec, ...
        'ub',        me.th_ub_vec, ...
        'options',   opt.opt);
    gs = GlobalSearch;
    
    % Save inputs
    wrap_fit_input(me, 'globalsearch', ...
        'input', opt, ...
        'input_raw', varargin, ...
        problem, gs);
    
    % Run fitting
    [x, fval, exitflag, output, local_solutions] = run(gs, problem);
    
    % Save outputs & intermediate variables
    try
        wrap_fit_output(me, x, fval, exitflag, output, local_solutions);
    catch
        wrap_fit_output(me, nans(size(me.th_0_vec)), fval, exitflag, output, local_solutions);
    end
end

function [x, fval, exitflag, output] = patternsearch(me, varargin)
    % Adopted from Jian's Global Optimization Toolbox demo (dtb_demo.m)
    
    % Parse input
    opt = varargin2S(varargin, { ...
        'local_fun', @fmincon, ...
        'opt', {}, ...
        'ps_opt', {}, ...
        });
    
    % local solver options - % TODO: chain local solver to patternsearch
%     if isstruct(opt.opt), opt.opt = S2C(opt.opt); end
%     opt.opt = varargin2C(opt.opt, { ...
%         'Algorithm',    'active-set', ...
%         'FinDiffType',  'central', ...
%         'UseParallel',  'always', ...
%         });
%     opt.opt = optimoptions(opt.local_fun, opt.opt{:});
%     
    % patternsearch options
    if isstruct(opt.ps_opt), opt.ps_opt = S2C(opt.ps_opt); end
    opt.ps_opt = varargin2C(opt.ps_opt, { ...
        'CompletePoll', 'on', ...
        'Cache',        'on', ...
        'Vectorized',   'off', ...
        'TolMesh',      0.001, ...
        'UseParallel',  'always', ...
        });
    opt.ps_opt = psoptimset(psoptimset(@patternsearch), opt.ps_opt{:});
    
    % Save inputs
    wrap_fit_input(me, 'patternsearch', ...
        'input', opt, ...
        'input_raw', varargin);
    
    % Run fitting
    [x, fval, exitflag, output] = patternsearch( ...
        @me.cost, me.th_0_vec, [], [], [], [], ...
        me.th_lb_vec, me.th_ub_vec, [], opt.ps_opt);
    
    % Save outputs & intermediate variables
    wrap_fit_output(me, x, fval, exitflag, output);
end

function [C, SS] = parse_fminsearchbnd_input(me, varargin_C)
    % [C, SS] = parse_fminsearchbnd_input(Flow, {'param_name1', param1, ...});
    %
    % param: One of 'x0', 'lb', 'ub', 'opt'.
    % See help fmincon for details.
    % Leave unspecified to use the default value from modules.
    % Note that the cost function is always the method Flow.cost().
    %
    % See also: fmincon
    
    SS = varargin2S(varargin_C, {...
        'x0',   me.th_0_vec, ...
        'LB',   me.th_lb_vec, ...
        'UB',   me.th_ub_vec, ...
        'opt',  [], ...
        }, 2);
    if iscell(SS.opt), SS.opt = varargin2S(SS.opt); end
    SS.opt = optimset(SS.opt);
    
    % Set MaxFunEval following MaxIter
    if isempty(SS.opt.MaxFunEvals) && ~isempty(SS.opt.MaxIter)
        SS.opt.MaxFunEvals = SS.opt.MaxIter * 10;
    end
    
    C = struct2cell(SS);
end

function [C, SS] = parse_fmincon_input(me, varargin_C)
    % [C, SS] = parse_fmincon_input(Flow, {'param_name1', param1, ...});
    %
    % param: One of 'x0', 'A', 'B', 'Aeq', 'Beq', 'lb', 'ub', 'nonlcon', 'opt'.
    % See help fmincon for details.
    % Leave unspecified to use the default value from modules.
    % Note that the cost function is always the method Flow.cost().
    %
    % See also: fmincon
    
    SS = varargin2S(varargin_C, {...
        'x0',   me.th_0_vec, ...
        'A',    [], ...
        'B',    [], ...
        'Aeq',  [], ...
        'Beq',  [], ...
        'LB',   me.th_lb_vec, ...
        'UB',   me.th_ub_vec, ...
        'nonlcon',  [], ...
        'opt',  [], ...
        });
    if ~isempty(SS.opt)
        SS.opt = varargin2S(SS.opt, {...
            'Algorithm',    'active-set', ...
            'FinDiffType',  'central', ...
            'UseParallel',  'always', ...
            });
    end
    SS.opt = optimset(SS.opt);
    
    % Set MaxFunEval following MaxIter
    if isempty(SS.opt.MaxFunEvals) && ~isempty(SS.opt.MaxIter)
        SS.opt.MaxFunEvals = SS.opt.MaxIter * 10;
    end
    
    C = struct2cell(SS);
end

function wrap_fit_input(me, method_name, varargin)
    % wrap_fit_input(me, method_name, varargin)
    
    me.res = struct;
    me.res.method = method_name;
    
    me.res = pack_varargin(varargin, inputnames('varargin'), me.res);
end

function wrap_fit_output(me, x, fval, exitflag, output, varargin)
    % wrap_fit_output(me, x, fval, exitflag, output, varargin)
    
    me.th_vec = x;
    me.res.th = me.th;
    
    me.res = mergeStruct(me.res, packStruct(x, fval, exitflag, output));
    me.res = pack_varargin(varargin, inputnames('varargin'), me.res);
    me.res.S = me.S;
    
    copy_res(me);
end

%% S-related (intermediate variables)
function assign_S(me, f, v)
    % ASSIGN_S  Assign v into field S.(f).
    % : In case S.(f) exists already and its value differs from v, issues error.
    
    if isfield(me.S, f)
        if ~isequal(me.S.(f), v)
            error('Flow.S.%s already exists with different value!', f);
        end
    else
        me.S.(f) = v;
    end
end

%% Dependent properties
function n = get.n_module(me)
    n = length(me.modules);
end

function v = get.dat_names(me)
    v = me.dat.Properties.VarNames;
end

function set.dat_names(me, v)
    % Add columns of NaNs if necessary.
    nam = setdiff(v, me.dat_names, 'stable');
    C   = cell(1, length(nam) * 2);
    C(1:2:end) = nam;
    C(2:2:end) = num2cell(nan(1, length(nam)));
    me.dat = ds_set(me.dat, ':', C{:});
    
    % Permute order & remove superfluous columns.
    me.dat = me.dat(:, v); 
end

function v = get.n_th(me)
    v = length(me.th_names);
end

function v = get.th_names(me)
    v = fieldnames(me.th)'; % row vector
end

function set.th_names(me, v)
    names = setdiff(v(:)', me.th_names, 'stable');
    
    for c_name = names
        me.th.(c_name{1}) = nan;
    end
end

function set.th_vec(me, v)
    me.th = cell2struct( num2cell(v(:)'), me.th_names(:)', 2);
end

function set.th_0_vec(me, v)
    me.th_0 = cell2struct( num2cell(v(:)'), me.th_names(:)', 2);
end

function set.th_ub_vec(me, v)
    me.th_ub = cell2struct( num2cell(v(:)'), me.th_names(:)', 2);
end

function set.th_lb_vec(me, v)
    me.th_lb = cell2struct( num2cell(v(:)'), me.th_names(:)', 2);
end

function v = get.th_vec(me)
    v = cell2vec( struct2cell( me.th ) );
end

function v = get.th_0_vec(me)
    v = cell2vec( struct2cell( me.th_0 ) );
end

function v = get.th_ub_vec(me)
    v = cell2vec( struct2cell( me.th_ub ) );
end

function v = get.th_lb_vec(me)
    v = cell2vec( struct2cell( me.th_lb ) );
end

function set.dat_mat(me, v)
    for i_dat = 1:length(me.dat_names)
        c_dat = me.dat_names{i_dat};
        
        me.dat.(c_dat) = v(:, i_dat);
    end
end

function v = get.dat_mat(me)
    v = ds2mat(me.dat);
end

function set.modules_S(me, v)
    % Update modules and module_names.
    module_names = fieldnames(v)';
    modules      = struct2cell(v)';
    
    for i_module = 1:length(modules)
        modules{i_module}.tag = module_names{i_module};
    end
    
    me.modules = modules;
end 

function v = get.modules_S(me)
    if isempty(me.modules)
        v = struct; % So that its size is 1 x 1, not 0 x 1.
    else
        v = cell2struct(me.modules, me.module_names, 2);
    end
end

function set.modules(me, v)
    % Update module_names{k} following modules{k}.tag
    me.modules = v;
    
    module_names = cell(1, length(v));
    for i_module = 1:length(me.modules)
        module_names{i_module} = me.modules{i_module}.tag;
    end
    me.module_names = module_names;
end
end

methods (Static)
%% Load/Save
function me = loadobj(me)
    if ~isa(me, 'Fit_flow')
        me = copyfields(Fit_flow, me);
    end
         
    is_legacy = (isempty(fieldnames(me.f_init_S)) && ~isempty(me.f_inits)) ...
             || (isempty(fieldnames(me.f_pred_S)) && ~isempty(me.f_preds)) ...
             || (isempty(fieldnames(me.f_cost_S)) && ~isempty(me.f_costs));
    
    if is_legacy
        for cc_kind = {'init', 'pred', 'cost'}
            c_kind = cc_kind{1};
            
            f_S = ['f_' c_kind '_S'];
            fs  = ['f_' c_kind 's'];
            
            c_fs = me.(fs)(:)';
            
            fun_names = csprintf([c_kind, '_%d'], 1:length(c_fs));
            
            me.(f_S) = cell2struct(c_fs, fun_names, 2);
            me.(fs) = fun_names;
        end
    end
end
end
end