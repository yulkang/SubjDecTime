classdef TxtVarList < handle
    properties
        % L.(name): struct with the following fields.
        %   v    : value.
        %   kind : 'a' (absolute continuous), 'r' (relative continuous), or 'd' (discrete)
        %   range: cont: {lo, up}; disc: {v1, v2, ...}
        %   scale: cont: increment/decrement. disc: always 1.
        %   fmt  : as in sprintf(fmt, v)
        L = struct; 
        col_names = TxtVarList.default_col_names;
        
        % S_fmt.field: if set to '%1.1f', the example output will be:
        %   field: 10.5 {0.0, 1.0} (+-0.5)  % if not chosen
        % > field: 10.5 {0.0, 1.0} (+-0.5)  % if chosen
        % {}, commas, and () are added automatically.
        S_fmt = struct
        
        c_row_name = ''; % current row name
        
        max_line = inf;
        
        txt_C = {};
        
        draw_on_update = false;
    end
    
    properties (Dependent)
        row_names
        c_ix_row = 1; % which variable to edit
        c_row % current struct. L.(me.c_row_name).
        n_row
    end
    
    properties (Constant)
        default_col_names = {'name', 'v', 'kind', 'range', 'scale', 'fmt'};
    end
    
    methods
        function me = TxtVarList(vars, varargin)
            % TxtVarList  Generic variable modifier.
            %
            % me = TxtVarList(vars, ['prop1', prop1, ...])
            %
            % vars
            % : cell array with rows of 
            %   {'name', 'v', 'kind', 'range', 'scale', 'fmt'}
            %
            % name
            % : string
            %
            % v
            % : numeric ('a'|'r') or string ('d') value.
            %
            % kind
            % : 'a'|'r'|'d'
            %
            % range
            % : {min,max} ('a' or 'r')
            %   {val1, val2, ...} ('d')
            %
            % scale
            % : scalar. Ignored for 'd'.
            %
            % fmt
            % : e.g., '%1.0f', '%s'
            %
            % 2014 (c) Yul Kang. hk2699 at columbia dot edu.
            
            % Init variables
            if nargin > 0 && ~isempty(vars)
                init_vars(me, vars);
            end
            
            varargin2fields(me, varargin);
        end
        
        function init_vars(me, vars)
            % vars: a cell matrix with rows of
            % {var_name, default, kind='a'|'r'|'d', range={}, scale}
            
            if iscell(vars{1})
                % Convert into the cell matrix format
                n_col_all = length(TxtVarList.default_col_names);
                c_vars = cell(length(vars), n_col_all);
                
                for i_row = 1:length(vars)
                    n_col = min(length(vars{i_row}), n_col_all);
                    
                    % Default to absolute continuous.
                    if n_col < 3, vars{i_row}{3} = 'a'; n_col = 3; end
                    
                    c_vars(i_row, 1:n_col) = vars{i_row}(1:n_col);
                    
                    % Autofill missing variables
                    switch vars{i_row}{3}
                        case 'd'
                            assert(n_col >= 4, 'range is required for discrete variables!');
                            if n_col < 5, c_vars{i_row, 5} = 1; end
                            if n_col < 6, c_vars{i_row, 6} = '%s'; end
                            
                        case {'a', 'r'}
                            if n_col < 4, c_vars{i_row, 4} = {0, inf}; end
                            if n_col < 5, c_vars{i_row, 5} = significant_digit(c_vars{i_row, 2}); end
                            
                            sc = c_vars{i_row, 5};
                            
                            if n_col < 6
                                c_vars{i_row, 6} = fmt_significant_digit(sc);
                            end
                    end
                end
                vars = c_vars;
            end
            
            col = cell2struct(num2cell(1:length(me.col_names)), ...
                              me.col_names, 2);

            % Check input
            assert( all(cellfun(@ischar, vars(:,col.name))),        'name error');                
            assert( all(bsxEq(          [vars{:,col.kind}], 'ard')),'kind error');
            assert( all(cellfun(@iscell, vars(:,col.range))),       'range error');
            assert( all(isnumeric(      [vars{:,col.scale}])),      'scale error');
            assert( all(cellfun(@ischar, vars(:,col.fmt))),         'fmt error');                

            for ii = 1:size(vars,1)
                if vars{ii,col.kind} == 'd'
                    assert(ismember(vars{ii,col.v}, vars{ii,col.range}), ...
                        'v out of range');
                else
                    assert(all((vars{ii,col.range}{1} <= vars{ii,col.v}) ...
                             & (vars{ii,col.v}        <= vars{ii,col.range}{2})), ...
                        'v out of range');
                end

                % Construct L from vars
                me.L.(vars{ii,col.name}) = cell2struct( ...
                    vars(ii,:), me.col_names, 2);
            end
            
            % Fill txt_C
            n = size(vars, 1);

            if isempty(me.c_row_name) || ~any(strcmp(me.c_row_name, me.row_names))
                me.c_row_name = me.row_names{1};
            end

            cont  = bsxEq(cell2mat(vars(:,col.kind)), 'ar')';
            fmt   = vars(:,col.fmt);
            v     = vars(:,col.v);
            range = vars(:,col.range);
            scale = vars(:,col.scale);
            name  = vars(:,col.name);

            s_cur    = repmat({'  '}, [n,1]);
            s_cur{me.c_ix_row} = '>>';

            s_val   = cell(n,1);
            s_range = cell(n,1);
            s_scale = cell(n,1);

            if any(cont)
                s_val(cont)   = cellfun(@(f,vv) sprintf(f,vv), fmt(cont), v(cont), 'UniformOutput', false);
                s_range(cont) = cellfun(@(f,vv) sprintf([f ', ' f], vv{1}, vv{2}), fmt(cont), range(cont), 'UniformOutput', false);
                s_scale(cont) = cellfun(@(f,vv) sprintf(['(+-' f ')'], vv), fmt(cont), scale(cont), 'UniformOutput', false);
            end

            if any(~cont)
                s_val(~cont)   = cellfun(@(f,vv) sprintf(f,vv), fmt(~cont), v(~cont), 'UniformOutput', false);
                s_range(~cont) = cellfun(@(f,vv) sprintf([f ', '], vv{:}), fmt(~cont), range(~cont), 'UniformOutput', false);
                s_scale(~cont) = repmat({''}, [1, nnz(~cont)]);
            end

            me.txt_C = cellfun(@(varargin) sprintf('%s %s: %s, {%s} %s\n', varargin{:}), s_cur, name, s_val, s_range, s_scale, 'UniformOutput', false);
        end
        
        function [change_in_val, changed_var, changed_val] = change_var(me, op, var_name, val)
            % [change_in_val, changed_var, changed_val] = change_var(me, op, [var_name, val])
            %
            % op: 'prev', 'next', 'inc', 'dec', 'inc_scale', 'dec_scale'
            %     'set'
            
            change_in_val = false;
            changed_val   = nan;
            
            switch op
                case 'set'
                    me.L.(var_name).v = val;
                    change_in_val = true;
                    changed_var   = var_name;
                    changed_val   = val;

                    me.set_txt(changed_var);
                                        
                case 'inc'
                    row = me.c_row;
                    
                    switch row.kind
                        case 'a'
                            row.v = min(row.range{2}, row.v + row.scale);
                        case 'r'
                            row.v = min(row.range{2}, row.scale);
                        case 'd'
                            row.v = row.range{mod(find(strcmp(row.v, row.range)), ...
                                length(row.range)) + 1};
                    end
                    
                    me.c_row = row;
                    change_in_val = true;
                    changed_var = me.c_row_name;
                    changed_val = me.c_row.v;
                    
                    me.set_txt(changed_var);
                    
                case 'dec'
                    row = me.c_row;
                    
                    switch row.kind
                        case 'a'
                            row.v = max(row.range{1}, row.v - row.scale);
                        case 'r'
                            row.v = max(row.range{1}, -row.scale);
                        case 'd'
                            row.v = row.range{mod(find(strcmp(row.v, row.range)) - 2, ...
                                length(row.range)) + 1};
                    end
                    
                    me.c_row = row;
                    change_in_val = true;
                    changed_var = me.c_row_name;
                    changed_val = me.c_row.v;
                    
                    me.set_txt(changed_var);
                    
                case 'choose'
                    c_ix = find(strcmp(var_name, me.row_names));
                    
                    if isempty(c_ix)
                        fprintf('No row named %s!\n', var_name); % DEBUG
                    else
                        fprintf('Choose %s (%d)\n', var_name, c_ix); % DEBUG
                        
                        prev_var = me.c_row_name;
                    
                        me.c_ix_row = c_ix;
                        changed_var = me.c_row_name;
                        
                        me.set_txt(prev_var);
                        me.set_txt(changed_var);
                    end
                    
                case {'prev', 'prev5th'}
                    prev_var = me.c_row_name;
                    
                    if strcmp(op, 'prev'), rel_ix = -1; else rel_ix = -5; end
                    
                    c_ix = rel_ix_var(me, rel_ix);
                    me.c_ix_row = c_ix;
                    changed_var = me.c_row_name;
                    
                    me.set_txt(prev_var);
                    me.set_txt(changed_var);
                    
                case {'next', 'next5th'}
                    prev_var = me.c_row_name;
                    
                    if strcmp(op, 'next'), rel_ix = 1; else rel_ix = 5; end
                    
                    c_ix = rel_ix_var(me, rel_ix);
                    me.c_ix_row = c_ix;
                    changed_var = me.c_row_name;
                    
                    me.set_txt(prev_var);
                    me.set_txt(changed_var);
                    
                case 'inc_scale'
                    if any(me.c_row.kind == 'ar')
                        me.c_row.scale = me.c_row.scale * 10;
                    end
                    changed_var = me.c_row_name;
                    change_in_val = false;
                    
                    me.set_txt(changed_var);
                    
                case 'dec_scale'
                    if any(me.c_row.kind == 'ar')
                        me.c_row.scale = me.c_row.scale / 10;
                    end
                    changed_var = me.c_row_name;
                    
                    me.set_txt(changed_var);
                    
                otherwise
                    return; % Ignore unknown op.
            end          
            
            if me.draw_on_update
                draw(me);
            end
        end
        
        function draw(me)
            home;
            disp('-----TxtVarList.txt-----');
            disp(me.L2txt);
        end
        
        %% Internal
        function t = L2txt(me)
            if isinf(me.max_line)
                t = [me.txt_C{:}];
            else
                n_st = floor(me.max_line/2);
                
                ix = me.rel_ix_var((-n_st) : ceil(me.max_line/2));
                
                t = [me.txt_C{ix}];
            end
        end        
        
        function ix = rel_ix_var(me, rel)
            % ix = rel_ix_var(me, rel)
            
            ix = mod(me.c_ix_row - 1 + rel, me.n_row) + 1;
        end
        
        function set_txt(me, var_name)
            if strcmp(me.c_row_name, var_name)
                str_ind = '>>';
            else
                str_ind = '  ';
            end
            
            me.txt_C{strcmp(var_name, me.row_names)} = [str_ind, ...
                TxtVarList.row2txt(me.L.(var_name))];
        end
        
        %% Get/Set functions
        function v = get.row_names(me)
            v = fieldnames(me.L);
        end
        
        function v = get.c_ix_row(me)
            v = find(strcmp(me.c_row_name, me.row_names));
        end
        
        function set.c_ix_row(me, v)
            me.c_row_name = me.row_names{v};
        end
        
        function v = get.c_row(me)
            v = me.L.(me.c_row_name);
        end
        
        function set.c_row(me, v)
            me.L.(me.c_row_name) = v;
        end
        
        function v = get.n_row(me)
            v = length(me.txt_C);
        end
    end
    
    methods (Static)
        function txt = row2txt(row)
            % txt = row2txt(row)
            
            fmt = row.fmt;
            
            if any(row.kind == 'ar')
                txt = sprintf( ...
                    sprintf(' %%s: %s, {%s, %s} (+-%s)\\n', fmt, fmt, fmt, fmt), ...
                    row.name, row.v, row.range{1}, row.range{2}, row.scale);
            else
                txt = sprintf(' %s: %s, {%s}\n', ...
                    row.name, ...
                    sprintf(row.fmt, row.v), ...
                    sprintf([row.fmt, ', '], row.range{:}));
            end
        end
        
        function C = test_var
            disp(TxtVarList.default_col_names);
            C = {
                'A',  1,    'a', {0,10},             1, '%1.1f'
                'B',  'bb', 'd', {'bb', 'cc', 'dd'}, 1, '%s'
                'CC', 0,    'r', {-10,10},           1, '%1.2f'
                'D',  1,    'a', {0,10},             1, '%1.1f'
                'E',  'bb', 'd', {'bb', 'cc', 'dd'}, 1, '%s'
                'F',  0,    'r', {-10,10},           1, '%1.2f'
                };
        end
        
        function me = test(skip_op)
            % me = test(skip_op=false)
            
            if nargin == 0, skip_op = false; end
            
            C = TxtVarList.test_var;
        
            me = TxtVarList(C, 'max_line', 3);
            me.draw_on_update = true;
            me.draw;
            
            if ~skip_op
                for c_op = {'inc', 'dec_scale', 'dec', 'inc_scale', ...
                            'next', 'next', 'next', 'prev', 'prev', ...
                            'inc', 'inc', 'inc', 'dec', 'dec', 'next', 'inc', 'dec'}
                    input(sprintf('Press enter for ''%s'' op: ', c_op{1}), 's');
                    me.change_var(c_op{1});
                end

                input('Press enter for ''set A 5'' op: ', 's');
                me.change_var('set', 'A', 5);

                input('Press enter for ''set B dd'' op: ', 's');
                me.change_var('set', 'B', 'dd');
            end
        end
    end
end