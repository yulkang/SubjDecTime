classdef Fit_module_symmetric < Fit_module_flexible
properties
    postfix = '';
    symmetry_enabled = {};
    symmetric = {};
    symmetry_flag = struct;
end

methods
    function me = Fit_module_symmetric(postfix, varargin)
        if exist('postfix', 'var')
            me.postfix = postfix;
        end
        
        if ~isempty(varargin)
            me.init_module(varargin{:});
        end
    end
    
    function init_module(me, name_pairs, param_pairs, c_dat_names, varargin)
        % INIT_MODULE  Add 'up' and 'lo' to names before adding postfixes.
        %
        % init_module(me, name_pairs, param_pairs, c_dat_nemas, ['property_name1', property_value1, ...])
        %
        % name_pairs: {'name1', guess1, 'name2', guess2, ...}
        %
        % name
        % (1) Symmetry-enabled names
        %   : When the name is included in the cell array me.symmetry_enabled, 
        %     give the name without me.postfix. The postfix will be attached
        %     after attaching symmetry-related postfixes like _up, _lo, _sym, and _both.
        %
        % (2) Other names
        %   : Give names *with* the postfix, as in me.s.
        %
        % guess:
        %   {{th0_up, lb_up, ub_up}, {th0_lo, lb_lo, ub_lo}, 'same'|'opposite'}
        %   : th0, lb, ub for b_lo, b_up.
        %
        %   {{th0, lb, ub}, {}, 'same'}
        %   : th0, lb, ub are the same for _up and _lo.
        %     Equivalent to {{th_0, lb, ub}, {th_0, lb, ub}, 'same'}
        %
        %   {{th0, lb, ub}, {}, 'opposite'}
        %   : th0, lb, ub are of the opposite signs for _up and _lo.
        %     Equivalent to {{th_0, lb, ub}, {-th_0, -ub, -lb}, 'opposite'}
        %
        %   : When 'name' is included in me.symmetric, the guess for 
        %     _up is taken as the guess for _sym. Then it is copied to
        %     _up. Finally, it is copied to _lo if the flag is 'same',
        %     and its additive comlpement is copied to _lo if the flag is
        %     'opposite'.
        %
        % See also Fit_module, Fit_module_flexible
            
        % Get parameter values
        varargin2fields(me, varargin, false);
        
        % Add name maps
        if ~exist('name_pairs', 'var'), name_pairs = {}; end
        if ~iscell(name_pairs), name_pairs = {name_pairs}; end
        me.add_map(name_pairs{:});
            
        % Parse parameter names and guesses
        if ~exist('param_pairs', 'var'), param_pairs = {}; end
        if ~exist('c_dat_names', 'var'), c_dat_names = {}; end
        
        % Initialize name-guess pair variables
        n_pairs = length(param_pairs)/2;
        params  = cell(1, n_pairs);
        guesses = cell(1, n_pairs);
        i_pair  = 0;
        
        % Parse name-guess pairs.
        for i_name = 1:2:length(param_pairs)
            c_name  = param_pairs{i_name};
            c_guess = param_pairs{i_name + 1};
            
            if any(strcmp(c_name, me.symmetry_enabled))
                % Check guess format
                assert(iscell(c_guess) && length(c_guess)==3 ...
                        && iscell(c_guess{1}) && iscell(c_guess{2}) ...
                        && ischar(c_guess{3}), ...
                    ['Guess for %s has wrong format!\n', ...
                     'It should be: ''name'', {{th0_up, lb_up, ub_up}, {th0_lo, lb_lo, ub_lo}, ''same''|''opposite''}\n', ...
                     'See help Fit_module_symmetric.init_module for correct input format!'], ...
                     c_name);
                
                % symmetry_flag
                assert(any(strcmp(c_guess{3}, {'same', 'opposite'})), ...
                    'symmetry_flag should be either ''same'' or ''opposite''!');
                
                me.symmetry_flag.(c_name) = c_guess{3};
                
                % Parse params and guesses to feed to init_module@Fit_module_flexible.
                if any(strcmp(c_name, me.symmetric))
                    i_pair = i_pair + 1;
                    params{i_pair}   = str_con(c_name, 'sym', me.postfix);
                    guesses{i_pair} = c_guess{1};
                else
                    i_pair = i_pair + 1;
                    params{i_pair}   = str_con(c_name, 'up', me.postfix);
                    guesses{i_pair} = c_guess{1};
                    
                    i_pair = i_pair + 1;
                    params{i_pair}   = str_con(c_name, 'lo', me.postfix);
                        
                    if isempty(c_guess{2})
                        switch me.symmetry_flag.(c_name)
                            case 'same'
                                guesses{i_pair} = c_guess{1};
                            case 'opposite'
                                % {th0, lb, ub} -> {-th0, -ub, -lb}
                                guesses{i_pair}{1} = -c_guess{1}{1};
                                guesses{i_pair}{2} = -c_guess{1}{3};
                                guesses{i_pair}{3} = -c_guess{1}{2};
                        end
                    else
                        guesses{i_pair} = c_guess{2};
                    end
                end
            else
                % Check guess format
                assert(iscell(c_guess) && isnumeric(c_guess{1}), ...
                    ['Guess for %s has wrong format!\n', ...
                     'It should be: {th0, lb, ub}, since it is not a symmetry-enabled parameter.\n', ...
                     'See help Fit_module_symmetric.init_module for correct input format!'], ...
                    c_name);
                
                % Parse params and guesses to feed to init_module@Fit_module_flexible.
                i_pair = i_pair + 1;
                params{i_pair} = c_name;
                guesses{i_pair} = c_guess;
            end
        end
        
        % Feed init_module@Fit_module_flexible
        me.init_module@Fit_module_flexible( {}, ...
            name_value2pair(params, guesses), ...
            c_dat_names);
    end
    
    function pred(me, fl)
        % pred  enforce symmetry and combine sides.
        %
        % See also enforce_symmetry, combine_sides
        
        me.enforce_symmetry(fl);
        me.combine_sides(fl);
        
        me.pred@Fit_module_flexible(fl)
    end
    
    function enforce_symmetry(me, fl, variables)
        % enforce_symmetry  Enforce symmetry of variable values.
        %
        % enforce_symmetry(me, fl, variables)
        % : If a variable V is included in me.symmetric, copy V_sym to V_up and V_lo, 
        %   flipping signs if me.symmetry_flag.(V) is 'opposite'.
        %
        % variables
        % : Cell array of variable names.
        %   If omitted, defaults to me.symmetric.
        
        if exist('variables', 'var')
            variables = variables(intersectCellStr(variables, me.symmetric));
        else
            variables = me.symmetric;
        end
        
        s = me.s;
        
        for i_variable = 1:length(variables)
            variable = variables{i_variable};
            
            up_name  = s.(str_con(variable, 'up'));
            lo_name  = s.(str_con(variable, 'lo'));
            sym_name = s.(str_con(variable, 'sym'));
            
            fl.S.(up_name) = fl.S.(sym_name);
            
            switch me.symmetry_flag.(variable)
                case 'same'
                    fl.S.(lo_name) = fl.S.(sym_name);
                case 'opposite'
                    fl.S.(lo_name) = -fl.S.(sym_name);
            end
        end   
    end
    
    function combine_sides(me, fl, variables)
        % combine_sides  Combine _lo and _up variables into _both.
        %
        % combine_sides(me, fl, variables)
        % : Sets V_both as [V_lo, V_up] for all V in variables.
        %
        % variables
        % : Cell array of variable names.
        %   If omitted, defaults to me.symmetry_enabled.
        
        if exist('variables', 'var')
            variables = variables(intersectCellStr(variables, me.symmetry_enabled));
        else
            variables = me.symmetry_enabled;
        end
        
        s = me.s;
        
        for i_variable = 1:length(variables)
            variable = variables{i_variable};
            
            up_name  = s.(str_con(variable, 'up'));
            lo_name  = s.(str_con(variable, 'lo'));
            both_name = s.(str_con(variable, 'both'));
            
            fl.S.(both_name) = [fl.S.(lo_name), fl.S.(up_name)];
        end
    end
    
    %% Subfunctions for init_module
    function s = map_postfix(me, src, postfix_dst, postfix_src)
        % map_postfix(me, src, postfix_dst, postfix_src)
        
        if ~exist('postfix_dst', 'var'), postfix_dst = ''; end
        if ~exist('postfix_src', 'var'), postfix_src = ''; end
        
        src_ena = intersect(src, me.symmetry_enabled);
        src_sym = intersect(src, me.symmetric);
        
        s = struct;
        
        % Symmetric names have 'param_sym_*'.
        s = copy_fields(s, Fit_module_flexible.map_postfix( ...
                src_sym, str_con('sym', postfix_dst), str_con('sym', postfix_src)), ...
                'all_recursive');
            
        % Symmetry-enabled names, whether they are chosen to be symmetric or not,
        % have 'param_lo_*', 'param_up_*', 'param_both_*'.
        s = copy_fields(s, Fit_module_flexible.map_postfix( ...
                src_ena, str_con('lo', postfix_dst), str_con('lo', postfix_src)), ...
                'all_recursive');
        s = copy_fields(s, Fit_module_flexible.map_postfix( ...
                src_ena, str_con('up', postfix_dst), str_con('up', postfix_src)), ...
                'all_recursive');
        s = copy_fields(s, Fit_module_flexible.map_postfix( ...
                src_ena, str_con('both', postfix_dst), str_con('both', postfix_src)), ...
                'all_recursive');
            
        % All names have 'param_*'.
        s = copy_fields(s, Fit_module_flexible.map_postfix( ...
                src, postfix_dst));
    end    
    
    function set.symmetric(me, v)
        to_enable_symmetry = setdiff(v, me.symmetry_enabled);
        
        if ~isempty(to_enable_symmetry)
            list_str = sprintf(' %s', to_enable_symmetry{:});
            error('Enable symmetry in%s by including them in Module.symmetry_enabled!', list_str);
        else
            me.symmetric = v;
        end
    end
end
end