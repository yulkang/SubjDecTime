classdef Fit_module_flexible < Fit_module
    properties
        s = struct; % maps one set of names onto another.
    end
    
    methods
        function init_module(me, name_pairs, varargin)
            % init_module(me, name_pairs, varargin)
            %
            % See also Fit_module, add_map
            
            if ~iscell(name_pairs), name_pairs = {name_pairs}; end
            me.add_map(name_pairs{:});
            
            me.init_module@Fit_module(varargin{:});
        end
        
        function add_map(me, varargin)
            % add_map(me, map1, map2, ...)
            % 
            % map_k
            % : Any one of 'name', {'name'}, {'name_src', 'name_dst'}, 
            %   or name_struct.
            %   The first two are the same as {'name_src', 'name_src'}.
            %   The last is a struct with (a part of) the mapping,
            %   s.(name_src) = name dst.
            
            for i_nam = 1:length(varargin)
                c_nam = varargin{i_nam};
                
                if iscell(c_nam)
                    if isscalar(c_nam)
                        me.s.(c_nam{1}) = c_nam{1};
                    else
                        me.s.(c_nam{1}) = c_nam{2};
                    end
                    
                elseif ischar(c_nam)
                    me.s.(c_nam) = c_nam;
                    
                elseif isstruct(c_nam)
                    me.s = copy_fields(me.s, c_nam, 'all_recursive');
                    
                else
                    error('each map should be either char (map onto itself) or a cell ({src} or {src, dst})!');
                end
            end
        end
    end
    
    methods (Static)
        function s = map_postfix(src, postfix_dst, postfix_src)
            % s = map_postfix(src, postfix_dst, postfix_src)
            %
            % src: a cell array of string names.
            % postfix: either a string or a cell array of strings.
            %
            % EXAMPLE 1:
            % s = Fit_module_flexible.map_postfix({'A', 'B'}, 'a')
            % s = 
            %     A: 'A_a'
            %     B: 'B_a'
            %
            % EXAMPLE 2:
            % s = Fit_module_flexible.map_postfix({'k', 'A'}, {'M', 'C'})
            % s = 
            %     k_1: 'k_M'
            %     A_1: 'A_M'
            %     k_2: 'k_C'
            %     A_2: 'A_C'
            
            % Defaults
            if ~exist('postfix_dst', 'var'), postfix_dst = ''; end
            if ~exist('postfix_src', 'var'), postfix_src = ''; end
            
            % Enforce row vector
            src = src(:)';
            
            if iscell(postfix_dst)
                s = struct;
                
                for ii = 1:length(postfix_dst)
                    s = copy_fields(s, ...
                            Fit_module_flexible.map_postfix(src, ...
                                postfix_dst{ii}, ...
                                sprintf('%d', ii)), 'all_recursive');
                end
                
            elseif ischar(postfix_dst)
                if ~isempty(postfix_dst)
                    % Put postfix
                    dst = cellfun(@(nam) [nam, '_' postfix_dst], src, ...
                        'UniformOutput', false);
                else
                    % Map to src itself, e.g., for backward compatibility.
                    dst = src; 
                end
                
                if ~isempty(postfix_src)
                    % Put postfix
                    src = cellfun(@(nam) [nam, '_' postfix_src], src, ...
                        'UniformOutput', false);
                end

                % Output
                s = cell2struct(dst, src, 2);
            else
                error('postfix should be either a string or cell of strings!');
            end
        end
    end
end