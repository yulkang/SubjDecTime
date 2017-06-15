classdef Fit_Flow2 < matlab.mixin.Copyable
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
            'fminsearchbnd', @(Fl) varargin2S({
                'PlotFcns',  Fl.plotfun
                'OutputFcn', Fl.outfun % includes Fl.OutputFcn, history, etc
                });
            'etc_',    @(Fl) varargin2S({}, {});
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
        nargin_fun = struct;
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
    end
    
    methods
        %% User Interface
        function [Fl, f] = Fit_Flow2(funs, params, dat)
            % [Fl, f] = Fit_Flow2(funs, params, dat)
            %
            % : Equivalent to:
            %
            %   Fl = Fit_Flow;
            %   add_fun(Fl, funs);
            %   add_th(Fl, params);
            %   Fl.dat = dat;
            %   f = cost_fun(Fl);
            %
            % General workflow
            % ----------------
            %
            % Fl = Fit_Flow2;
            % add_fun(Fl,{'fun_name', fun, {'out1', ...}; ...}) % Each row specifies one function.
            % add_th( Fl,{'th_name', th0, th_lb, th_ub; ...}) % Each row specifies one parameter.
            % f = cost_fun(Fl); % Returns a function handle.
            % th_fit = fmincon(f, Fl.th0_vec,[],[],[],[],Fl.th_lb_vec,Fl.th_ub_vec, ...); % Fit with the function handle.
            %
            % Functions
            % ---------
            % Each function has the following format:
            %   {out_1, ...} = fun(th, W, Fl)
            % where 
            %   th is a struct with parameters,
            %   W is the workspace struct, Fl.W. 
            %   Fl is the whole object. Fl.dat is the data.
            %   Always use W instead of Fl.W in the function,
            %   because W is cached inside Fl.run().
            % All inputs are optional.
            % The output is a cell array. Each element will be set to W.(out_k) 
            % after execution of the function.
            %
            % Workspace
            % ---------
            % At the end of Fl.run, which is run on every iteration, 
            % W is copied to Fl.W, and
            % W.cost is copied to Fl.cost.
            
            if nargin >= 1
                add_fun(Fl, funs);
            end
            if nargin >= 2
                add_fun(Fl, params);
            end
            if nargin >= 3
                Fl.dat = dat;
            end
            if nargout >= 2
                f = cost_fun(Fl);
            end
        end
        
        function add_fun_init(Fl, funs)
            % Shorthand for add_fun(Fl, {{... 'iter', false}, ...})
            %
            % add_fun_init(Fl, funs)
            
            for ii = 1:size(funs, 1)
                add_fun(Fl, funs{ii}{:}, 'iter', false);
            end
        end
        
        function add_fun(Fl, fun_name, fun_out, fun, varargin)
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
            % 'iter', true
            % 'use_varargout', false
            %
            % Functions
            % ---------
            % Each function has the following format:
            %   {out_1, ...} = fun(th, W, Fl)
            % where W is the workspace struct, Fl.W. 
            % All inputs are optional.
            % The output is a cell array. Each element will be set to W.(out_k) 
            % after execution of the function.
            
            if iscell(fun_name)
                for ii = 1:size(fun_name, 1)
                    add_fun(Fl, fun_name{ii}{:});
                end
                
            elseif ischar(fun_name)
                Fl.fun.(fun_name)        = fun;
                Fl.fun_out.(fun_name)    = fun_out;
                Fl.nargin_fun.(fun_name) = nargin(fun);
                
                S = varargin2S(varargin, {
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
        
        function add_th(Fl, th_name, th0, th_lb, th_ub)
            % add_th(Fl, 'th_name', th0, th_lb, th_ub)
            % add_th(Fl, {{'th_name', th0, th_lb, th_ub}, {...}, ...})
            %
            % Each row specifies one parameter. 
            % th0, th_lb, th_ub are scalar numericals.
            % When either th_lb or th_ub are omitted, they are set to
            % -inf and inf, respectively.
            
            if iscell(th_name)
                for ii = 1:size(th_name, 1)
                    add_th(Fl, th_name{ii}{:});
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
        
        function remove_th(Fl, th_name)
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
                
        function f = cost_fun(Fl)
            % Gives a function handle that can be fed to fmincon, etc.
            %
            % f = cost_fun(Fl)
            
            f = @(c_th) calc_cost(Fl, c_th);
        end
        
        function run_init(Fl)
            % Same as run(Fl) except this runs non-iterating functions.
            
            names = setdiff(Fl.fun_names, Fl.fun_iter, 'stable');
            run(Fl, names);
        end

        function run(Fl, names)
            % run(Fl, names)
            %
            % Runs Fl.fun.(names{k})

            fun = Fl.fun;
            fun_out = Fl.fun_out;
            nargin_fun = Fl.nargin_fun;
            fun_opt = Fl.fun_opt;
            
%             th = Fl.th;
            Fl.W  = copyFields(Fl.W, Fl.th);
            
            if nargin < 2, names = Fl.fun_iter; end
%             debug_mode = isequal(names, 'debug') || Fl.debug_mode;
%             if debug_mode
%                 names = Fl.fun_iter;
%                 fprintf('Debug mode. Run openvar W then type return. Press ENTER to proceed.\n');
%                 commandwindow;
%                 keyboard;
%             end
            if ~iscell(names), names = {names}; end
            
            if Fl.dbstop_if.naninf
                dbstop if naninf
            end
            
            for name = names
                n_argout = length(fun_out.(name{1}));
                
                if fun_opt.use_varargout.(name{1})
                    n_C = n_argout;
                    
                    % Run functions
                    switch nargin_fun.(name{1})
                        case 0
                            [C{1:n_C}] = fun.(name{1})();

                        case 1
                            [C{1:n_C}] = fun.(name{1})(Fl.th);

                        case 2
                            [C{1:n_C}] = fun.(name{1})(Fl.th, Fl.W);

                        case 3
                            [C{1:n_C}] = fun.(name{1})(Fl.th, Fl.W, Fl);
                    end
                else
                    % Run functions
                    switch nargin_fun.(name{1})
                        case 0
                            C = fun.(name{1})();

                        case 1
                            C = fun.(name{1})(Fl.th);

                        case 2
                            C = fun.(name{1})(Fl.th, Fl.W);

                        case 3
                            C = fun.(name{1})(Fl.th, Fl.W, Fl);
                    end
                end
                
                % Copy results
                for ii = 1:n_argout
                    if ~isempty(fun_out.(name{1}){ii})
                        Fl.W.(fun_out.(name{1}){ii}) = C{ii};
                    end
                end
                
%                 % Debug mode
%                 if debug_mode
%                     fprintf('%10s: [', name{1});
%                     fprintf('%s,', fun_out.(name{1}){:});
%                     fprintf('] = %s', func2str(fun.(name{1})));
%                     commandwindow;
%                     input(' ', 's');
%                 end
            end % To debug, put breakpoint here and run openvar W
            
            % Debug
            if isinf(Fl.W.cost) && Fl.W.cost > 0 && Fl.debug.cost_inf2realmax
                Fl.W.cost = realmax;
            end
            
            if isnan(Fl.W.cost) && Fl.debug.cost_nan2realmax
                Fl.W.cost = realmax;
            end    
            
            if any(~isreal(Fl.th_vec)) && Fl.debug.th_imag2realmax
                Fl.W.cost = realmax;
            end
            
            if ~isfinite(Fl.W.cost) || any(~isfinite(Fl.th_vec))
                warning('cost or at least one of the parameters is not finite!');
                eprintf Fl.W.cost
                eprintf Fl.th
                keyboard;
            end
            
            if Fl.dbstop_if.naninf
                dbclear if naninf
            end
            
%             % Copy W back to Fl
%             Fl.W = W;
            
            try
                % Copy cost from the workspace, W.
                Fl.cost = Fl.W.cost;
            catch err
                warning(err_msg(err));
            end            
        end
        
        function res2W(Fl, res)
            % Given res or from Fl.res, set th and run to construct W.
            %
            % res2W(Fl, res)
            
            if nargin >= 2 && ~isempty(res), Fl.res = res; end
            
            Fl.th = Fl.res.th;
            Fl.run;
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
        function [res, W] = fit(Fl, optim_fun, args, opts, outs)
            
            if isa(optim_fun, 'char')
                nam = optim_fun;
                optim_fun = evalin('caller', ['@' nam]);
            elseif isa(optim_fun, 'function_handle')
                nam = char(optim_fun);                
            else
                error('optim_fun must be either a function name or a function handle!');
            end
            
            if nargin < 3, args = {}; end
            if nargin < 4, opts = {}; end
            
            % Arguments
            try
                args = varargin2S(args, Fl.fit_arg.(nam)(Fl));
            catch
                args = varargin2S(args, Fl.fit_arg.etc_(Fl));
            end
            
            % OutputFcn
            if Fl.save_history
                Fl.init_history
            end
            
            % Options
            try
                opts = varargin2S(opts, Fl.fit_opt.(nam)(Fl));
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
                    outs = Fl.fit_out.(nam);
                catch
                    outs = Fl.fit_out.etc_;
                end
            end
            
            n_outs = length(outs);
            C_args = struct2cell(args);
            
            % Run optimization
            Fl.n_iter = 0;
            [c_outs{1:n_outs}] = optim_fun(C_args{:});
           
            % Store in res
            res.optim_fun_name = nam;
            res.out  = cell2struct(c_outs(:), outs(:), 1);
            res.arg  = args;
            res.arg.th0 = Fl.th0;
            res.opt  = opts;
            try
                res.th = vec2th_S(res.out.x(:)');
            catch
                res.th = vec2th_S(nan(1, length(Fl.th_names)));
            end
            try
                res.out.se = hVec(diag(inv(res.out.hessian)));
                assert(length(res.out.se) == length(Fl.th_names));
            catch
            end           
            
            res = Fit_Flow2.res_func2str(res);
            
            % Clean up history
            if Fl.save_history
                n_iter = res.out.output.iterations;
                res.history = Fl.res.history(1:(n_iter+1),:);
            end
            
            Fl.res = res;
            Fl.res2W;
            
            if nargout >= 2, W = Fl.W; end
            
            function S = vec2th_S(vec)
                S = cell2struct(num2cell(vec(:)'), Fl.th_names, 2);
            end
        end
        
        function [res, res_all] = fit_grid(Fl, spec, fit_opt, grid_opt)
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
                    spec_range{ispec} = parse_spec(spec_nam{ispec}, spec_range{ispec});
                end
                
                [comb, ncomb] = factorize(spec_range);
            end
            
            function cspec = parse_spec(nam, cspec)
                % Coerce into a cell form
                if isnumeric(cspec)
                    if isscalar(cspec)
                        cspec = parse_spec(nam, ...
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
                    fval_min = res_all{ii}.out.fval;
                end
            end
            
            %% Output
            res.grid = packStruct(res_all, grid_opt, spec_nam, comb, ncomb);
            
            Fl.res = res;
        end
        
        function res = fit_grid_cell(Fl, comb, spec_nam, fit_opt, grid_opt)    
            % Called from fit_grid.
            
            cFl = copy(Fl);

            nspec = length(spec_nam);
            
            for jj = 1:nspec
                cFl.th0.(spec_nam{jj})   = comb{jj}(1);

                if grid_opt.restrict
                    cFl.th_lb.(spec_nam{jj}) = comb{jj}(2);
                    cFl.th_ub.(spec_nam{jj}) = comb{jj}(3);
                end
            end

            res = fit(cFl, fit_opt{:});
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
                cOutputFcns = [{Fl.record_history}, cOutputFcns(:)'];
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
            
            function stop = c_outfun(x, optimValues, state)
                fprintf('Iter %4d (fval=%1.5g)', optimValues.iteration, optimValues.fval);
                cfprintf(' %s=%1.5g', th_names, x);
                stop = false;
            end
        end
        
        function f = record_history(Fl)
            f = @c_outfun;
            
            function stop = c_outfun(~, optimValues, state)
                % Flag
                stop = false;
                
                % Record history
                iter = optimValues.iteration + 1;
                
                Fl.res.history.cost(iter, 1) = optimValues.fval;
                Fl.res.history = ds_set(Fl.res.history, iter, Fl.th);  
            end
        end
        
        function init_history(Fl)
            Fl.res.history = ds_set(dataset, Fl.th);
            Fl.res.history.cost(1000,1) = 0;
        end
        
        function f = PlotFcn(Fl, to_plot, varargin)
            % f = PlotFcn(Fl, to_plot, varargin)
            %
            % to_plot: {'fig_tag', 'x_var', y_var'}
            
            f = @c_plotfun;
            
            S = varargin2S(varargin, {
                'per_iter', 1 % Plot every PER_ITER iterations.
                });
            if ~iscell(to_plot), to_plot = {to_plot}; end
            n_plot = length(to_plot);
            
            function stop = c_plotfun(~, optimValues, state)
                
                stop = false;
                if mod(optimValues.iteration, S.per_iter) ~= 0, return; end
                
                for ii = 1:n_plot
                    c_plot = to_plot{ii};
                    
                    fig_tag(c_plot{1});
                    
                    if ischar(c_plot{2}) && length(c_plot) >= 3
                        plot(Fl.W.(c_plot{2}), Fl.W.(c_plot{3}));
                    end
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
        
        %% Internal
        function c_cost = calc_cost(Fl, vec)
            % c_cost = calc_cost(Fl, vec)
            
            Fl.n_iter = Fl.n_iter + 1;
            
            Fl.th_vec = vec;
            Fl.run;
            c_cost = Fl.cost;
            
            if Fl.disp_cost
                fprintf('cost: %10d ', c_cost);
                fprintf('th: ');
                fprintf(' %10d', vec);
                fprintf('\n');
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
        
        function set.th_vec(Fl, v)
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
        
        %% Save
        function v = saveobj(Fl)
            v = copy(Fl);
            
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
        end
    end
    methods (Static)
        function res = res_func2str(res)
            try res.arg.fun = func2str(res.arg.fun); catch, end
            try res.arg.options.PlotFcns = cellfun(@func2str, ...
                    res.arg.options.PlotFcns, 'UniformOutput', false); catch, end
            try res.arg.options.OutputFcn = ...
                    func2str(res.arg.options.OutputFcn); catch, end
            try res.opt = res.arg.options; catch, end
        end
            
        %% Load
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
                    Fit_Flow2.resave(f{ii});
                end
            else
                L = load(f); %#ok<NASGU>
                save(f, '-struct', 'L');
                fprintf('Fit_Flow2.resave : Resaved %s\n', f);
            end
        end
    end
end

