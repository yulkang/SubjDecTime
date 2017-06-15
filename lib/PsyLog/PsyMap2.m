classdef PsyMap2
    % Quickly maps row vector(s) to number(s) or cell(s).
    % PsyMap uses MATLAB's sub2ind and ind2sub for robustness.
    %
    % me = PsyMap(key_fun, key_max, value_type='num', spar=true)
    % 
    %     key_fun    : row vector (find value), or empty (raw value)
    %     key_max    : maximum number of key variations for raw values.
    %     value_type : 'num' (default) or 'cell'
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
        key_names = {};
    end
    
    properties (SetAccess = protected)
        % key_max: maximum value of each column.
        key_max = [];
        
        % key_fun: function handle | row vector (find value) | empty (raw value).
        %
        % function handle: converts given key value to index.
        % row vector: key value's location within the vector is the key index.
        % empty: key value is given to directly equal the key index.
        key_fun = {};
        
        % col_fun: [k1, k2, ...] that key_fun{k} is function handle
        col_fun = [];
        
        % col_vec: [k1, k2, ...] that key_fun{k} is a row vector.
        col_vec = [];
        
        % col_raw: [k1, k2, ...] that key_fun{k} is empty. 
        % The index is used as provided for these columns.
        col_raw = [];
        
        % value: value connected to the key.
        value
    end
    
    properties (Dependent)
        n_col % Number of keys == length of key_fac
        value_type % Either 'cell' or 'num'
    end
    
    methods
        function me = PsyMap2(key_fun, key_max, value_type, spar, varargin)
            % me = PsyMap(key_fun, key_max, value_type, spar=true)
            % 
            % key_fun    : row vector (find value), or empty (raw value) 
            % key_max    : maximum number of key variations, in case of raw values.
            % value_type : 'num' (default) or 'cell'
            
            if ~exist('value_type', 'var') || isempty(value_type), value_type = 'num'; end
            if ~exist('spar', 'var') || isempty(spar), spar = true; end
            
            % key_fun
            me.key_fun = key_fun;
            
            is_fun     = cellfun(@(f) isa(f, 'function_handle'), key_fun);
            me.col_fun = find( is_fun );
            
            is_vec     = ~is_fun & ~cellfun(@isempty, key_fun);
            me.col_vec = find( is_vec );
            
            is_raw     = ~is_fun & ~is_vec;
            me.col_raw = find( is_raw );
            
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
            
            me = varargin2fields(me, varargin, false);
        end
        
        function key = row2key(me, row)
            C = cell(1, me.n_col);
            
            if ~isvector(row{1})
                row = mat2cell(row{1}, size(row{1},1), ones(1, size(row{1}, 2)));
            end
            
            for i_col = me.col_vec
                C{i_col}  = bsxFind(row{i_col}(:),  me.key_fun{i_col});
            end
            C(me.col_raw) = row(me.col_raw);
            
%             for i_col = me.col_fun % TODO
%                 row(:,i_col) = c_f(row(:,i_col));
%             end
            
            c_key_max = me.key_max;
            if isscalar(c_key_max), c_key_max = [c_key_max, 1]; end
            
            key = sub2ind(c_key_max, C{:});
        end
        
        function row = key2row(me, key)
            c_key_max = me.key_max;
            if isscalar(c_key_max), c_key_max = [c_key_max, 1]; end
            
            [C{1:me.n_col}] = ind2sub(c_key_max, key(:));
            row = cell2mat(C')';
            
%             for i_col = me.col_fun % TODO
%                 error('Column %d: inverse transform unsupported yet!', i_col);
%             end
            
            for i_col = me.col_vec
                row(:,i_col) = me.key_fun{i_col}(row(:,i_col));
            end
        end
        
        function n = get.n_col(me)
            n = length(me.key_max);
        end
        
        function res = subsref(me, S)
            % val = Map([key1, key2, ...])
            %
            % keys are column vectors of key values.
            
            if ~isscalar(S)
                error('Only one level of reference is allowed!');
            elseif strcmp(S.type, '.')
                res = me.(S.subs);
            else
                key = me.row2key(S.subs);
                
                switch S.type
                    case '()'
                        res = me.value(key);
                    case '{}'
                        res = me.value{key};
                    otherwise
                        error('S.type of ''%s'' is not allowed!', S.type);
                end
            end
        end
        
        function me = subsasgn(me, S, v)
            % Map([key1, key2, ...]) = 
            
            if ~isscalar(S)
                error('Only one level of reference is allowed!');
            elseif strcmp(S.type, '.')
                me.(S.subs) = v;
            else
                key = me.row2key(S.subs);
                
                switch S.type
                    case '()'
                        me.value(key) = v;
                    case '{}'
                        me.value{key} = v;
                    otherwise
                        error('S.type of ''%s'' is not allowed!', S.type);
                end
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
end