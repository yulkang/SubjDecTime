classdef Fit_module < matlab.mixin.Copyable
    properties
        th_names = {};
        th_0     = struct;
        th_lb    = struct;
        th_ub    = struct;
        
        dat_names = {};
        
        f_init    = [];
        f_pred    = [];
        f_cost    = [];
        
        tag      = ''; % Identifier
    end
    
    properties (Dependent)
        n_th
    end
    
    methods
        function me = Fit_module(varargin)
            % Fit_module  A step in fitting, combined into Fit_flow.
            %
            % Module = Fit_module(param_pairs, dat_names, 'fun_kind1', fun1, ...)
            %
            % param_pairs
            % : {'param_name1', param_guess1, ...}
            %
            %   param_guess
            %   : In one of the following formats.
            %
            %     param_guess   : a numeric scalar guess, unbounded.
            %     param_guesses : a numeric vector guesses, unbounded. (Not supported yet)
            %     {param_guesses, param_min, param_max}: scalar min and max.
            %
            % fun_kind: 'f_init', 'f_pred', or 'f_cost'.
            %
            % 'f_init' function
            % : Called once before iteration for Initialization.
            %   Give @f_init whose input/output format is:
            %     I = f_init(fl);    
            %
            % 'f_pred' function
            % : Called every iteration for Prediction.
            %   Give @f_pred whose input/output format is:
            %     P = f_pred(fl); 
            %   
            %   - Before any f_pred is evaluated, Fit_module copies all
            %   fields of th (parameters) into P, for convenience and
            %   performance. So don't implement it in f_pred.
            %   
            %   - Use P.(param) instead of th.(param) to allow other modules
            %   to change the parameter value.
            %
            % 'f_cost' function
            % : Called every iteration for cost calculation.
            %   Give @f_cost whose input/output format is:
            %     c = f_cost(fl); 
            %
            % fl is a Fit_flow object. You can also modify object directly
            % within the function.
            %
            % For 'f_init' and 'f_pred' functions, one can supply
            %   {'field1', @fun1, ...}. 
            % Then for 'f_init' functions, the struct 'I' will be updated
            % sequentially like the following:
            %   fl.I.(field1) = fun1(fl)
            %   fl.I.(field2) = fun2(fl)
            %   ...
            % For 'f_pred' functions, the struct 'P' will be updated:
            %   fl.P.(field1) = fun1(fl)
            %   ...
            %
            % For 'f_cost' functions, one can supply 
            %   {fun1, fun2, ...} 
            % (without field names, because c is just a scalar numeric) to evaluate
            %   fl.c = fun1(fl)
            %   ...
            %
            % Finally, for all three kinds of functinos, one can subclass
            % Fit_module and modify .init, .pred, and .cost methods.
            % It is convenient if a particular parameter guess/lb/ub
            % and init/pred/cost function settings are used repeatedly.
            % Modifying methods also reduces ~25% of speed overhead,
            % although the speed overhead is small either way:
            % 1.2ms per cost evaluation for anonymous functions and
            % 0.9ms for modified methods on 2.8GHz Quad-core i7.
            %
            % Rationale for the 3-kind system and the input/output formats
            % ------------------------------------------------------------
            % - Since some calculations are needed only initially but some
            % are needed on every iteration, it helps to separate
            % 'f_init' from 'f_pred'.
            % - Since fitting functions require one numeric output as a cost value,
            % the separation of 'f_pred' from 'f_cost' is necessary.
            % - Since struct can contain any data, the restriction of
            % single output per function preserves generality. 
            % - All information from previous & current steps are passed
            % as arguments, again preserving generality.
            %
            % EXAMPLE:
            %
            % See also Fit_flow
            %
            % 2014 (c) Yul Kang. hk2699 at columbia dot edu.
            
            me.tag = class(me);
            
            if nargin > 0
                me.init_module(varargin{:});
            end
        end
        
        function init_module(me, param_pairs, c_dat_names, varargin)
            % INIT_MODULE  Actual initialization happens here.
            %
            % init_module(me, param_pairs, c_dat_names, varargin)
            %
            % See also Fit_module.
            
            if ~exist('param_pairs', 'var'), param_pairs = {}; end
            if ~exist('c_dat_names', 'var'), c_dat_names = {}; end

            % Parse functions and other properties
            me = varargin2fields(me, varargin, false);
            
            % Parse parameter names and guesses
            if ~isempty(param_pairs)
                assert(isNameValuePair(param_pairs), ...
                    'Second argument should be a cell vector of name-value pairs!');
                
                for i_param = 1:(length(param_pairs) / 2)

                    nam = param_pairs{i_param * 2 - 1};
                    val = param_pairs{i_param * 2};

                    me.th_names{i_param} = nam;

                    if isempty(val)
                        me.th_0.(nam)  = [];
                        me.th_lb.(nam) = [];
                        me.th_ub.(nam) = [];
                    
                    elseif isnumeric(val)
                        me.th_0.(nam)  = val;
                        me.th_lb.(nam) = -inf;
                        me.th_ub.(nam) = inf;
                        
                    elseif iscell(val)
                        me.th_0.(nam)  = val{1};
                        me.th_lb.(nam) = val{2};
                        me.th_ub.(nam) = val{3};
                    end
                end
            end
            
            % Assign data names
            me.dat_names = c_dat_names;            
        end
        
        %% Function parsers
        % Either modify these in subclasses or assign function handles to f_*.
        function varargout = init(me, fl)
            % I = me.init(fl)
            
            [varargout{1:nargout}] = parse_fun(me, 'f_init', fl);
        end
        
        function varargout = pred(me, fl)
            % P = me.pred(fl)
            
            [varargout{1:nargout}] = parse_fun(me, 'f_pred', fl);
        end
        
        function varargout = cost(me, fl)
            % c = me.cost(fl)
            
            [varargout{1:nargout}] = parse_fun(me, 'f_cost', fl);
        end
        
        function varargout = parse_fun(me, kind, fl)
            % R = parse_fun(me, kind, fl)
            
            if ~isempty(me.(kind))
                if iscell(me.(kind))
                    if strcmp(kind, 'f_cost')
                        for i_fun = 1:length(me.(kind))
                            fl.c = me.(kind){i_fun}(fl);
                        end                        
                    else                        
                        for i_fun = 2:2:length(me.(kind))
                            fl.S.(me.(kind){i_fun-1}) = me.(kind){i_fun}(fl);
                        end                                          
                    end
                    
                    if nargout > 0
                        varargout{1} = fl.(prop);
                    end
                else
                    [varargout{1:nargout}] = me.(kind)(fl);
                end
            end
        end
        
        %% Dependent properties
        function v = get.n_th(me)
            v = length(me.th_names);
        end
    end
end