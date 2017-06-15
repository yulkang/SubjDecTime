classdef PsyMap
    % Quickly maps row vector(s) to number(s) or cell(s).
    %
    % me = PsyMap(key_fun, key_max, value_type='num', spar=true)
    % 
    %     key_fun    : row vector (find value), or empty (raw value)
    %     key_max    : maximum number of key variations for raw values.
    %     value_type : 'num' (default) or 'cell'
    %     spar       : store value in a sparse matrix (defaults to true),
    %                  which is faster especially when keys are large.
    %
    % EXAMPLE:
    % >> Map = PsyMap({'AHV', [], [], [], []}, [5 10 10 1000]);
    % >> Map(['A' 2 5 5 150; 'V' 2 5 5 200]) = [3 10];
    % >> v = Map(['V' 2 5 5 200; 'A' 2 5 5 150])
    % v =
    %    (1,1)       10
    %    (2,1)        3
    %
    % See also: containers.Map
    %
    % Yul Kang (c) 2013, hk2699 at columbia dot edu.

    properties        
        key_name = {};
    end
    
    properties (SetAccess = protected)
        % key_max: maximum value of each column, except for the last one.
        key_max = [];
        
        % key_fac: used internally to compute value's index.
        key_fac = [];
        
        % key_fun: function handle | row vector (find value) | empty (raw value).
        %
        % function handle: converts given key value to index.
        % row vector: key value's location within the vector is the key index.
        % empty: key value is given to directly equal the key index.
        key_fun = {};
        
        % col_fun(k): true if key_fun{k} is function handle
        col_fun = [];
        
        % col_vec(k): true if key_fun{k} is a row vector.
        col_vec = [];
        
        % value: value connected to the key.
        value
    end
    
    properties (Dependent)
        n_col % Number of keys == length of key_fac
        value_type % Either 'cell' or 'num'
    end
    
    methods
        function me = PsyMap(key_fun, key_max, value_type, spar)
            % me = PsyMap(key_fun, key_max, value_type, spar=true)
            % 
            % key_fun    : row vector (find value), or empty (raw value) 
            % key_max    : maximum number of key variations, in case of raw values.
            % value_type : 'num' (default) or 'cell'
            
            if ~exist('value_type', 'var'), value_type = 'num'; end
            if ~exist('spar', 'var'), spar = true; end
            
            % key_fun
            me.key_fun = key_fun;
            
            is_fun     = cellfun(@(f) isa(f, 'function_handle'), key_fun);
            me.col_fun = find( is_fun );
            
            is_vec     = ~is_fun & ~cellfun(@isempty, key_fun);
            me.col_vec = find( is_vec );
            
            is_raw     = ~is_fun & ~is_vec;
            
            if any(is_fun) % TODO
                error('function handles are not supported yet!');
            end
            
            % key_max
            for i_col = me.col_vec
                me.key_max(i_col) = length(me.key_fun{i_col});
            end
            if any(is_raw)
                me.key_max(is_raw) = key_max;
            end
            
            % key_fac
            me.key_fac = PsyMap.key_max2key_fac(me.key_max);
            
            switch value_type
                case 'num'
                    if spar
                        me.value = sparse(prod(me.key_max),1);
                    else
                        me.value = zeros(prod(me.key_max),1);
                    end 
                case 'cell'
                    me.value   = cell(prod(me.key_max),1);
                otherwise
                    error('value_type should be either num or cell!');
            end
        end
        
        function key = row2key(me, row)
            for i_col = me.col_vec
                row(:,i_col) = bsxFind(row(:,i_col), me.key_fun{i_col});
            end
            
%             for i_col = me.col_fun % TODO
%                 row(:,i_col) = c_f(row(:,i_col));
%             end
            
            key = sum(bsxfun(@times, row, me.key_fac), 2);
        end
        
        function row = key2row(me, key)
            key = key(:);
            row = zeros(length(key), me.n_col);
            
            for i_key = length(me.key_fac):-1:1
                row(:,i_key) = floor(key / me.key_fac(i_key));
                key = rem(key, me.key_fac(i_key));
            end
            
%             for i_col = me.col_fun % TODO
%                 error('Column %d: inverse transform unsupported yet!', i_col);
%             end
            
            for i_col = me.col_vec
                row(:,i_col) = me.key_fun{i_col}(row(:,i_col));
            end
        end
        
        function n = get.n_col(me)
            n = length(me.key_fac);
        end
        
        function res = subsref(me, S)
            % val = Map([key1, key2, ...])
            %
            % keys are column vectors of key values.
            
            if length(S) > 1
                error('Only one level of reference is allowed!');
            elseif strcmp(S.type, '()')
                key = me.row2key(S.subs{1});
                res = me.value(key);
            elseif strcmp(S.type, '{}')
                key = me.row2key(S.subs{1});
                res = me.value{key};
            else
                res = me.(S.subs);
            end
        end
        
        function me = subsasgn(me, S, v)
            % Map([key1, key2, ...]) = 
            
            if length(S) > 1
                error('Only one level of reference is allowed!');
            elseif strcmp(S.type, '()')
                key = me.row2key(S.subs{1});
                me.value(key) = v;
            elseif strcmp(S.type, '.')
                me.(S.subs) = v;
            else
                error('Only () or . are allowed!');
            end
        end
        
        function t = get.value_type(me)
            if iscell(me.value)
                t = 'cell';
            else
                t = 'num';
            end
        end
    end
    
    methods (Static)
        function key_fac = key_max2key_fac(key_max)
            key_fac = [1, cumprod(fliplr(key_max(1:(end-1))))];
        end
    end
end