classdef Fit_Flow4
    % - Makes Fit_Flow3 a value class to workaround MATLAB bugs
    % - Simplifies functions - they get W only.
    %
    % The motivation is to make input-output relationship
    % flexible and transparent in the script,
    % facilitating combination and reuse of existing functions.
    % 
    % The method add_fun() allows arbitrary input-output relationship,
    % while the property W provides the common workspace.
    
    properties
        W     = struct; % workspace
        
        %% Parameters
        th    = struct; % struct of thetas
        th0   = struct; % struct of initial guesses
        th_lb = struct; % struct of lower bounds
        th_ub = struct; % struct of upper bounds
        
        %% Data
        dat  = dataset; % dataset of data.f
        dat_path = '';  % path to find the data. If specified, save/load from/to the path 
                        % rather than saving the data with Fl.
        
        %% Optimization
        % current scalar cost.
        cost = inf; 
        
        % constraints: See help fmincon_cond
        constr = {};
        
        % res.(solver)
        % : Last fit result from the solver.
        %   Fields: Copy of the properties - fit_arg, fit_opt, fit_res
        res  = struct; 
        
        % fit_arg.(solver)
        % : Struct of default positional arguments for the solver.
        %   Field order determines the arguments' order.
        fit_arg = varargin2S({}, {
            'fmincon', @(Fl) varargin2S({
                'fun', Fl.cost_fun
                'x0',  Fl.th0_vec
                'A',   []
                'b',   []
                'Aeq', []
                'beq', []
                'lb',  Fl.th_lb_vec
                'ub',  Fl.th_ub_vec
                'nonlcon', []
                'options', {}
                });
            'fminsearchbnd', @(Fl) varargin2S({
                'fun', Fl.cost_fun
                'x0',  Fl.th0_vec
                'lb',  Fl.th_lb_vec
                'ub',  Fl.th_ub_vec
                'options', {}
                });
            'etc_', @(Fl) varargin2S({
                'fun', Fl.cost_fun
                'x0',  Fl.th_vec
                });
            });
        
        % fit_opt.(solver)
        % : Struct of default options for the solver.
        fit_opt = varargin2S({}, {
            'fmincon', @(Fl) varargin2S({
                'PlotFcns',  Fl.plotfun
                'OutputFcn', Fl.outfun % includes Fl.OutputFcn, history, etc
                });
            'fminsearchbnd' @(Fl) varargin2S({
                'PlotFcns',  Fl.plotfun
                'OutputFcn', Fl.outfun % includes Fl.OutputFcn, history, etc
                });
            'etc_',    @(Fl) varargin2S({}, {});
            });
        
        % handle_mode
        % : If true, assigns W back to Fl.W on every evaluation (see cost_fun()).
        %   Useful in plotting but may be incompatible with parallel processing.
        handle_mode = false; 
        plot_opt = varargin2S({}, {
            'per_iter', 1 % Plot on every iteration
            });
        
        % fit_out.(solver)
        % : Cell array of output names from the solver.
        fit_out = varargin2S({}, {
            'fmincon',      {'x', 'fval', 'exitflag', 'output', 'lambda', 'grad', 'hessian'}
            'fminsearchbnd',{'x', 'fval', 'exitflag', 'output'}
            'MultiStart',   {'x', 'fval', 'exitflag', 'output', 'solutions'}
            'etc_',         {'x', 'fval'}
            });
        
        % History
        n_iter              = 0;
        max_iter            = 1000;
        save_history        = true;
        disp_cost           = false;
        
        % Cell array of plot functions, evaluated in sequence
        PlotFcns = {
            };
        
        % Cell array of output functions, evaluated in sequence
        OutputFcns = {
            };
        
        %% Functions
        fun  = struct;
        fun_out = struct;
%         nargin_fun = struct; % Unused in Fit_Flow3
        fun_opt = struct; % fun_opt.(opt).(fun)
        fun_iter   = {}; % Functions to include in the interation.
        
        %% Debug
        debug_mode = false;
        dbstop_if = varargin2S({}, {
            'naninf', false
            });
        debug = varargin2S({}, {
            'cost_inf2realmax', true
            'cost_nan2realmax', true
            'th_imag2realmax', true
            });
    end
    
    properties (Dependent)
        th_vec % vector of thetas
        th0_vec
        th_ub_vec
        th_lb_vec
        th_names
        
        funs
        fun_names
        fun_init
    end
    
    properties (Transient)
        % Functions
        f_record_history    = [];
        f_calc_cost_iter    = [];
        f_calc_cost_init    = [];
    end
    
    methods
        %% User Interface
        function Fl = add_fun_init(Fl, funs)
            % Shorthand for add_fun(Fl, {{... 'iter', false}, ...})
            %
            % Fl = add_fun_init(Fl, funs)
            
            for ii = 1:size(funs, 1)
                Fl = add_fun(Fl, funs{ii}{:}, 'iter', false);
            end
        end
        
        function Fl = add_fun(Fl, fun_name, fun_out, fun, varargin)
            % add_fun(Fl, 'fun_name', {'out_1', 'out_2', ...}, fun, 'opt1', opt1, ...)
            % add_fun(Fl, {
            %   {'fun_name', {'out_1', 'out_2', ...}, fun, 'opt1', opt1, ...}
            %   {...}
            %   ...
            %   })
            %
            % If iter = true (default), the function is run on every
            % iteration during fitting.
            % If iter = false, the function can still be run manually
            % by run(Fl, {'function_name'}).
            %
            % Options, defaults
            % -----------------
            % 'inp',  {} % give W as the input argument. To give fields, specify their names.
            % 'iter', true
            % 'use_varargout', false
            %
            % Functions
            % ---------
            % Each function has one of the following formats:
            %   W = fun(W)            % Saves memory, but harder to make as a one-liner
            %   {out_1, ...} = fun(W) % Easy to write one-liner
            %   [out_1, ...] = fun(W.(in_1), ...) % Can reuse existing functions
            %
            % where W is the workspace struct, Fl.W. 
            % All inputs are optional.
            % The output is a cell array. Each element will be set to W.(out_k) 
            % after execution of the function.
            
            if iscell(fun_name)
                for ii = 1:size(fun_name, 1)
                    Fl = add_fun(Fl, fun_name{ii}{:});
                end
                
            elseif ischar(fun_name)
                Fl.fun.(fun_name)        = fun;
                Fl.fun_out.(fun_name)    = fun_out;
%                 Fl.nargin_fun.(fun_name) = nargin(fun); % unused in Fit_Flow3
                
                % Default fun_opt
                S = varargin2S(varargin, {
                    'inp',  {} % List of input fields. Omit to give W itself. New in Fit_Flow3, to allow direct incorporation of existing functions
                    'iter', true
                    'use_varargout', false
                    });
                
                for opt = fieldnames(S)'
                    Fl.fun_opt.(opt{1}).(fun_name) = S.(opt{1});
                end
                
                if S.iter
                    Fl.fun_iter = union(Fl.fun_iter, {fun_name}, 'stable');
                end
            else
                error('The first argument must be either cell or char!');
            end
        end
        
        function Fl = add_th(Fl, th_name, th0, th_lb, th_ub)
            % add_th(Fl, 'th_name', th0, th_lb, th_ub)
            % add_th(Fl, {{'th_name', th0, th_lb, th_ub}, {...}, ...})
            %
            % Each row specifies one parameter. 
            % th0, th_lb, th_ub are scalar numericals.
            % When either th_lb or th_ub are omitted, they are set to
            % -inf and inf, respectively.
            
            if iscell(th_name)
                for ii = 1:size(th_name, 1)
                    Fl = add_th(Fl, th_name{ii}{:});
                end
                
            elseif ischar(th_name)
                Fl.th.(th_name)    = th0;
                Fl.th0.(th_name)   = th0;
                
                if nargin >= 4
                    Fl.th_lb.(th_name) = th_lb;
                else
                    Fl.th_lb.(th_name) = -inf;
                end
                if nargin >= 5
                    Fl.th_ub.(th_name) = th_ub;
                else
                    Fl.th_ub.(th_name) = inf;
                end
            else
            end
        end
        
        function Fl = remove_th(Fl, th_name)
            % Remove parameter(s).
            % 
            % remove_th(Fl, th_name)
            %
            % th_name : char or cell.
            
            Fl.th    = rmfield(Fl.th, th_name);
            Fl.th0   = rmfield(Fl.th0, th_name);
            Fl.th_lb = rmfield(Fl.th_lb, th_name);
            Fl.th_ub = rmfield(Fl.th_ub, th_name);
        end
                
        function f = cost_fun(Fl, op)
            % Gives a function handle that can be fed to fmincon, etc.
            %
            % f = cost_fun(Fl, op='iter'|'init')
            
            if nargin < 2, op = 'iter'; end
            assert(any(strcmp(op, {'iter', 'init'})), 'op must be either iter or init!');
            
            prop_fun = ['fun_' op];
            
            if Fl.handle_mode
                % Save results to Fl.W and Fl.cost.
                % Useful in plotting but may be incompatible with parallel processing.
                f = @calc_cost_handle;
            else
                % Gives values only - W, fun
                W = Fl.W; % DEBUG
                
                f = @(c_th) Fit_Flow3.calc_cost(c_th, Fl.th_names, W, Fl.fun, ...
                    Fl.fun_out, Fl.fun_opt, Fl.(prop_fun), ...
                    Fl.calc_cost_opt_C);
            end
            
            function [cost, W] = calc_cost_handle(c_th)
                % Save results to Fl.W and Fl.cost
                [cost, W] = Fit_Flow3.calc_cost(c_th, Fl.th_names, Fl.W, Fl.fun, ...
                    Fl.fun_out, Fl.fun_opt, Fl.(prop_fun), ...
                    Fl.calc_cost_opt_C);
                
                Fl.W = W;
                Fl.cost = cost;
            end
        end
        
        function Fl = run_init(Fl)
            % Same as run(Fl) except this runs non-iterating functions.
            
            Fl = run(Fl, Fl.fun_init);
        end

        function [Fl, cost, W] = run(Fl, names)
            % [Fl, cost, W] = run(Fl, names)
            %
            % Runs Fl.fun.(names{k})

            if nargin < 2, names = Fl.fun_iter; end
            
            if Fl.dbstop_if.naninf
                dbstop if naninf
            end
            
            [Fl.cost, Fl.W] = Fit_Flow3.calc_cost(Fl.th_vec, Fl.th_names, Fl.W, ...
                Fl.fun, Fl.fun_out, Fl.fun_opt, names, Fl.calc_cost_opt_C);
            
            if Fl.dbstop_if.naninf
                dbclear if naninf
            end
            
            if nargout >= 1, cost = Fl.cost; end
            if nargout >= 2, W    = Fl.W;    end
        end
        
        function Fl = res2W(Fl, res)
            % Given res or from Fl.res, set th and run to construct W.
            %
            % res2W(Fl, res)
            
            if nargin >= 2 && ~isempty(res), Fl.res = res; end
            
            Fl.th = Fl.res.th;
            [~,~,Fl] = Fl.run;
        end
        
        function stop = runPlotFcns(Fl)
            f = Fl.plotfun;
            
            th_vec = Fl.th_vec;
            
            nf = length(f);
            nR = ceil(sqrt(nf));
            nC = ceil(nf / nR);
            
            state = 'done';
                    
            optimValues = varargin2S({}, {
                'funcCount', Fl.n_iter * length(th_vec)
                'fval',      Fl.cost
                'iteration', Fl.n_iter
                'procedure', []
                });
           
            stop = false;
            for ii = 1:length(f)
                subplot(nR, nC, ii);
                stop = stop || f{ii}(th_vec, optimValues, state);
            end
        end
        
        function stop = runOutputFcns(Fl)
            f = Fl.outfun;
            
            th_vec = Fl.th_vec;
            
            optimValues = varargin2S({}, {
                'funcCount', Fl.n_iter * length(th_vec)
                'fval',      Fl.cost
                'iteration', Fl.n_iter
                'procedure', []
                });
            
            stop = f(th_vec, optimValues, 'iter');            
        end
        
        %% Optimization interface
        function [res, W, Fl] = fit(Fl, optim_fun, args, opts, outs)
            
            if isa(optim_fun, 'char')
                optim_nam = optim_fun;
                optim_fun = evalin('caller', ['@' optim_nam]);
            elseif isa(optim_fun, 'function_handle')
                optim_nam = char(optim_fun);                
            else
                error('optim_fun must be either a function name or a function handle!');
            end
            
            if nargin < 3, args = {}; end
            if nargin < 4, opts = {}; end
            
            % Arguments - get from Fl.fit_arg.(optim_fun)
            try
                args = varargin2S(args, Fl.fit_arg.(optim_nam)(Fl));
            catch
                args = varargin2S(args, Fl.fit_arg.etc_(Fl));
            end
            
            % Options
            try
                opts = varargin2S(opts, Fl.fit_opt.(optim_nam)(Fl));
            catch
                opts = varargin2S(opts, Fl.fit_opt.etc_(Fl));
            end
            
            % Constraints
            if ~isempty(Fl.constr)
                C_constr = fmincon_cond(Fl);
                args = varargin2S({
                    'A',        C_constr{1}
                    'b',        C_constr{2}
                    'Aeq',      C_constr{3}
                    'beq',      C_constr{4}
                    'nonlcon',  C_constr{5}
                    }, args);
            end
            
            % Include in arguments only if nonempty
            if isfield(args, 'options')
                if isempty(args.options), args.options = {}; end
                args.options = varargin2S(opts, args.options);
            elseif ~isempty(opts)
                args.options = opts;
            end
            
            % Output
            if nargin < 5
                try
                    outs = Fl.fit_out.(optim_nam);
                catch
                    outs = Fl.fit_out.etc_;
                end
            end
            
            n_outs = length(outs);
            C_args = struct2cell(args);
            
            % history
            if Fl.save_history
                Fl.f_record_history([],[],'init'); % Initialize
            end
            
            % Run optimization
            tSt = datestr(now, 'HHMMSS.fff'); % DEBUG
            fprintf('Starting fmincon: %s\n', tSt); % DEBUG
            Fl.n_iter = 0;
            [c_outs{1:n_outs}] = optim_fun(C_args{:});
            fprintf('Finishing fmincon: %s\n', tSt); % DEBUG
            
            % Store in res
            res.optim_fun_name = optim_nam;
            res.out  = cell2struct(c_outs(:), outs(:), 1);
            res.arg  = args;
            res.arg.th0 = Fl.th0;
            res.opt  = opts;
            
            try
                res.fval = res.out.fval;
            catch
                res.fval = nan;
            end
            try
                res.th = vec2th_S(Fl, res.out.x(:)');
            catch
                res.th = vec2th_S(Fl, nan(1, length(Fl.th_names)));
            end
            try
                res.out.se = diag(inv(res.out.hessian));
                assert(all(size(res.out.se) == length(Fl.th_names)));
            catch
                res.out.se = nan(1, length(Fl.th_names));
            end           
            res.se = vec2th_S(Fl, res.out.se);
            
            res = Fit_Flow3.res_func2str(res);
            
            % Truncate history
            if Fl.save_history
                Fl.res.history = Fl.f_record_history([],[],'retrieve');
            end
            
            % Output
            [Fl.cost, Fl.W] = Fl.f_calc_cost_iter(res.out.x);
            Fl.res = res;
            
            if nargout >= 2, W = Fl.W; end
            
            function S = vec2th_S(Fl, vec)
                S = cell2struct(num2cell(vec(:)'), Fl.th_names, 2);
            end
        end
        
        function [res, res_all, Fl] = fit_grid(Fl, spec, fit_opt, grid_opt)
            % spec: empty: 
            %       {'var1', val1, ...}               : Use all combinations
            %       {{'var1', var2, ...}, {[x0_1_1, lb1_1, ub1_1], ...; [x0_2_1, lb2_1, ub2_1], ...}, ...}    : Use given combinations
            %
            % val : vector: evaluate within [val(1), val(2)], with an initial value of (val(1)+val(2))/2, then [val(2), val(3)], ...
            %       scalar: equivalent to giving linspace(lb, ub, val)
            %       cell  : evaluate within [val{1}(2), val{1}(3)], with an initial value of val{1}(1), then [val{2}(1), val{2}(2)], ...
            
            %% Parse spec - get spec_nam, nspec, comb, ncomb
            if isempty(spec)
                spec = arg2C([Fl.th_names(:), repmat({1}, [length(Fl.th_vec), 1])]);
            end
            
            if iscell(spec{1})
                spec_nam   = spec{1};
                comb       = spec{2};
                ncomb      = size(comb, 1);
            else
                spec_nam   = spec(1:2:end);
                spec_range = spec(2:2:end);
                nspec      = length(spec_nam);
            
                for ispec = 1:nspec
                    spec_range{ispec} = parse_spec(Fl, spec_nam{ispec}, spec_range{ispec});
                end
                
                [comb, ncomb] = factorize(spec_range);
            end
            
            function cspec = parse_spec(Fl, nam, cspec)
                % Coerce into a cell form
                if isnumeric(cspec)
                    if isscalar(cspec)
                        cspec = parse_spec(Fl, nam, ...
                            linspace(Fl.th_lb.(nam), Fl.th_ub.(nam), cspec + 1));
                    else
                        vec   = cspec;
                        nvec  = length(vec) - 1;
                        cspec = cell(1, nvec);
                        for kk = 1:nvec
                            cspec{kk} = [(vec(kk) + vec(kk+1))/2, vec(kk), vec(kk+1)];
                        end
                    end
                end
            end
            
            %% Parse opt
            grid_opt = varargin2S(grid_opt, {
                'restrict', true % Set to false to check global convergence.
                'parallel', false
                });
            
            if ncomb == 1, grid_opt.parallel = false; end
            
            %% Fit
            res_all  = cell(1,ncomb);

            if grid_opt.parallel
                parfor ii = 1:ncomb
                    disp(Fl.W);
                    res_all{ii} = fit_grid_cell(Fl, comb(ii,:), spec_nam, fit_opt, grid_opt);
                end
            else
                for ii = 1:ncomb
                    res_all{ii} = fit_grid_cell(Fl, comb(ii,:), spec_nam, fit_opt, grid_opt);
                end
            end
            
            %% Find minimum
            fval_min = inf;
            for ii = 1:ncomb
                if res_all{ii}.out.fval < fval_min
                    res = res_all{ii};
                end
            end
            
            Fl.res = res;
        end
        
        function res = fit_grid_cell(Fl, comb, spec_nam, fit_opt, grid_opt)    
            % Called from fit_grid.
            
            nspec = length(spec_nam);
            
            for jj = 1:nspec
                Fl.th0.(spec_nam{jj})   = comb{jj}(1);

                if grid_opt.restrict
                    Fl.th_lb.(spec_nam{jj}) = comb{jj}(2);
                    Fl.th_ub.(spec_nam{jj}) = comb{jj}(3);
                end
            end

            res = fit(Fl, fit_opt{:});
        end
        
        function res = fit_global(Fl, g_fun, g_opt, run_arg, loc_opt, loc_fun, loc_arg)
            % res = fit_global(Fl, g_fun, g_opt, run_arg, loc_opt, loc_fun=@fmincon, loc_arg)
            
            if nargin < 2, g_fun = 'MultiStart'; end
            if nargin < 3, g_opt = {}; end
            if nargin < 4, run_arg = {}; end
            if nargin < 5, loc_opt = {}; end
            if nargin < 6, loc_fun = @fmincon; end
            if nargin < 7, loc_arg = {}; end
            
            C_constr = fmincon_cond(Fl);
            loc_opt = varargin2C(loc_opt, {
                'Display',      'iter'
                'Algorithm',    'interior-point'
                'FinDiffType',  'central'
                'UseParallel',  'always'
                }, loc_opt);
            loc_optim = optimoptions(loc_fun, loc_opt{:});
            
            loc_arg = varargin2C(loc_arg, {
                'x0',           Fl.th0_vec
                'lb',           Fl.th_lb_vec
                'ub',           Fl.th_ub_vec
                'objective',    Fl.cost_fun
                'Aineq',        C_constr{1}
                'bineq',        C_constr{2}
                'Aeq',          C_constr{3}
                'beq',          C_constr{4}
                'nonlcon',      C_constr{5}
                'options',      loc_optim
                });
            problem = createOptimProblem(char(loc_fun), loc_arg{:});
                
            g_opt = varargin2C(g_opt, {
                'UseParallel',  true
                });
            
            switch g_fun
                case 'MultiStart'
                    if isempty(run_arg)
                        run_arg = {200}; % Number of runs
                    end
                    
                    g_obj = MultiStart(g_opt{:});
                    
                    % Fit and store results
                    res.optim_fun_name = g_fun;
                    res.out = out2S( ...
                        @() run(g_obj, problem, run_arg{:}), ...
                        Fl.fun_out.MultiStart);
                    res.arg = {g_fun, g_opt, run_arg, loc_opt, loc_fun, loc_arg};
                    
                    res = copyFields(res, packStruct(...
                        loc_optim, problem, g_opt, g_obj));
                    
                otherwise 
                    error('Not implemented yet!');
            end
        end
        
        function C = fmincon_cond(Fl)
            C = fmincon_cond(Fl.th_names, Fl.constr);
        end
        
        %% Output/plotting functions
        function f = outfun(Fl)
            % (1) Evaluate functions in Fl.OutputFcns 
            % (2) Also evaluate Fl.record_history
            
            cOutputFcns = Fl.OutputFcns;
            if Fl.save_history
                cOutputFcns = [{@Fl.f_record_history}, cOutputFcns(:)'];
            end
            
            f = @c_outfun;
            
            function stop = c_outfun(x, optimValues, state)
                stop = false;
                
                for ii = 1:length(cOutputFcns)
                    stop = stop || cOutputFcns{ii}(x, optimValues, state);
                end
            end
        end
        
        function f = plotfun(Fl)
            f = Fl.PlotFcns;
        end
        
        function f = dispfun(Fl)
            f = @c_outfun;
            th_names = Fl.th_names;
            
            function stop = c_outfun(x, optimValues, state)
                fprintf('Iter %4d (fval=%1.5g)', optimValues.iteration, optimValues.fval);
                cfprintf(' %s=%1.5g', th_names, x);
                stop = false;
            end
        end
        
        function f = record_history(Fl)
            % Gives Fl.f_record_history. Used in outfun.
            
            th_names = Fl.th_names;
            max_iter = Fl.max_iter;
            n_th     = length(th_names);
            
            f = @f_rec;
            
            function stop = f_rec(x, optimValues, state)
                persistent history
                
                % Flag
                stop = false;

                switch state
                    case 'init'
                        % Initialize
                        history = mat2dataset(zeros(max_iter,n_th), 'VarNames', th_names);

                    case 'iter'
                        % Record
                        for ii = 1:n_th
                            history.(th_names{ii})(optimValues.iteration + 1, 1) = x(ii);
                        end

                    case 'done'
                        % Truncate
                        history = history(1:min((optimValues.iteration + 1), end), :);

                    case 'retrieve'
                        % Return
                        stop = history;
                end
            end
        end
        
        function f = optimplotx(Fl)
            names = Fl.th_names;
            n     = length(names);
            ub    = Fl.th_ub_vec;
            lb    = Fl.th_lb_vec;
            
            f = @f_optimplotx;
            
            function stop = f_optimplotx(x,optimValues,state,varargin)
                
%                 persistent ht
                
                % Show normalized plot
                x_plot = (x - lb) ./ (ub - lb);
                
                barh(x_plot);
                
%                 stop = optimplotx(x_plot,optimValues,state,varargin{:});
%                 xlabel(''); % Remove the xlabel that obscures variable names in <R2014b.
                
                labels = cell(n,1);
                for ii = 1:n
                    labels{ii} = [
                        strrep(names{ii}, '_', '-'), ': ', ... % '\newline', ...
                        sprintf('%1.3g', x(ii)), ' ', ... % '\newline', ...
                        sprintf('(%1.2g - %1.2g)', lb(ii), ub(ii))];
                end  
                
                set(gca, 'YTick', 1:n, 'YTickLabel', labels, 'YDir', 'reverse');
                xlim([0 1]);
                ylim([0 n+1]);
                
%                 if verLessThan('matlab', '8.4')
%                     try delete(ht); catch, end
%                     ht = format_ticks(gca, labels);
%                 else
%                     set(gca, 'XTickLabel', labels);
%                 end
%                 ylim([0 1]);

                stop = false;
            end
        end
        
        %% Get/Set
        function v = get.th_vec(Fl)
            v = cell2mat(struct2cell(Fl.th))';
        end
        
        function v = get.th0_vec(Fl)
            v = cell2mat(struct2cell(Fl.th0))';
        end
        
        function v = get.th_ub_vec(Fl)
            v = cell2mat(struct2cell(Fl.th_ub))';
        end
        
        function v = get.th_lb_vec(Fl)
            v = cell2mat(struct2cell(Fl.th_lb))';
        end
        
        function Fl = set.th_vec(Fl, v)
            Fl.th = cell2struct(num2cell(v(:)), fieldnames(Fl.th), 1);
        end
        
        function v = get.th_names(Fl)
            v = fieldnames(Fl.th)';
        end
        
        function v = get.funs(Fl)
            v = struct2cell(Fl.fun)';
        end
        
        function v = get.fun_names(Fl)
            v = fieldnames(Fl.fun)';
        end
        
        function v = get.fun_init(Fl)
            v = setdiff(Fl.fun_names, Fl.fun_iter, 'stable');
        end
        
        function f = get.f_calc_cost_iter(Fl)
            if isempty(Fl.f_calc_cost_iter)
                f = Fl.cost_fun('iter');
            else
                f = Fl.f_calc_cost_iter;
            end
        end
        
        function f = get.f_calc_cost_init(Fl)
            if isempty(Fl.f_calc_cost_init)
                f = Fl.cost_fun('init');
            else
                f = Fl.f_calc_cost_init;
            end
        end
        
        function f = get.f_record_history(Fl)
            if isempty(Fl.f_record_history)
                f = Fl.record_history;
            else
                f = Fl.f_record_history;
            end
        end
        
        %% Internal
        function C = calc_cost_opt_C(Fl)
            % Make this agree with opt in calc_cost.
            
            C = varargin2C(Fl.debug);
        end
        
        %% Save
        function v = prepare_save(Fl) % saveobj(Fl)
            v = Fl;
            
            if ~isempty(v.dat_path)
                if exist(v.dat_path, 'file')
                    warning('%s already exists - skip saving. To update, delete existing file manually.', ...
                        v.dat_path);
                else
                    if ~exist(fileparts(v.dat_path), 'dir')
                        mkdir(fileparts(v.dat_path));
                    end
                    
                    dat = v.dat; %#ok<NASGU>
                    save(v.dat_path, 'dat');
                end
                
                % Erase dat
                v.dat = dataset;
            end
            
            v.W = struct;
            
            v.PlotFcns = func2str_C(v.OutputFcns);
            v.OutputFcns = func2str_C(v.OutputFcns);
            
            v.fun = func2str_S(v.fun);
        end
    end
    methods (Static)
        %% Fitting
        function [cost, W] = calc_cost(th_vec, th_names, W, fun, fun_out, fun_opt, fun_names, opt)
            % [cost, W] = calc_cost(th_vec, th_names, W, fun, fun_out, fun_opt, fun_names, opt)
            
            if nargin < 8
                opt = {};
            end
            opt = varargin2S(opt, {
                'cost_inf2realmax', true
                'cost_nan2realmax', true
                'th_imag2realmax', true
                });
            
            % Copy current function value
            nth = length(th_vec);
            for ith = 1:nth
                W.(th_names{ith}) = th_vec(ith);
            end
            
            % Which functions to run
            if nargin < 7 || isempty(fun_names)
                fun_names = fieldnames(fun)';
            end
            
            % Run functions     
            tSt = datestr(now, 'HHMMSS.fff'); % DEBUG
            disp(tSt); % DEBUG
            for ccfun = fun_names
                cfun = ccfun{1};
                
                fprintf('-- %s: %s\n', tSt, cfun); % DEBUG
                disp(W);
                fprintf('== %s: %s\n', tSt, cfun); % DEBUG
                
                W = S2io(W, fun.(cfun), fun_out.(cfun), fun_opt.inp.(cfun), ...
                    'use_varargout', fun_opt.use_varargout.(cfun));
            end
            
            try
                % Cost postprocessing
                if opt.cost_inf2realmax && isinf(W.cost)
                    cost = realmax;
                elseif opt.cost_nan2realmax && isnan(W.cost)
                    cost = realmax;
                elseif opt.th_imag2realmax && any(~isreal(th_vec))
                    cost = realmax;
                else
                    cost = W.cost;
                end
            
                if ~isfinite(cost) || any(~isfinite(th_vec))
                    warning('cost or at least one of the parameters is not finite!');
                    eprintf cost
                    eprintf th_vec
                    keyboard;
                end
            catch err
                warning(err_msg(err));
                cost = nan;
            end
        end
        
        %% Load
        function res = res_func2str(res)
            try res.arg.fun = func2str(res.arg.fun); catch, end
            try res.arg.options.PlotFcns = cellfun(@func2str, ...
                    res.arg.options.PlotFcns, 'UniformOutput', false); catch, end
            try res.arg.options.OutputFcn = ...
                    func2str(res.arg.options.OutputFcn); catch, end
            try res.opt = res.arg.options; catch, end
        end
            
        function Fl = loadobj(Fl)
            if ~isempty(Fl.dat_path)
                if exist(Fl.dat_path, 'file')
                    if isempty(Fl.dat)
                        load(Fl.dat_path, 'dat');
                        Fl.dat = dat; %#ok<CPROP>
                    else
                        warning('Neither dat nor dat_path is empty! Keeping dat and skipping loading...');
                    end
                end
            end
            C = cellfun(@str2func, Fl.funs, 'UniformOutput', false, ...
                    'ErrorHandler', @(err, arg) arg);
            Fl.fun = cell2struct(C, Fl.fun_names, 2);
        end
        
        function resave(f)
            if iscell(f)
                for ii = 1:numel(f)
                    Fit_Flow3.resave(f{ii});
                end
            else
                L = load(f); %#ok<NASGU>
                save(f, '-struct', 'L');
                fprintf('Fit_Flow3.resave : Resaved %s\n', f);
            end
        end
    end
end

