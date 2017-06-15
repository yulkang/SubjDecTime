classdef CodeClip
% Generates clips of code for OOP.
%
% .getsetfun_delegate_dep
% .getsetfun_delegate
% .getsetfun_and_dep
% .getsetfun_dep
% .getsetfun_dep_hidden
% .getsetfun
%
% See also: getsetfun, metaget, getsetfun_text, show_and_copy

% 2016-2017 (c) Yul Kang. hk2699 at columbia dot edu.
methods (Static)
    function c = getsetfun_delegate_dep(obj_name, delegator_name, ...
            prop_names, prefixes)
        % c = getsetfun_delegate_dep(obj_name, delegator_name, ...
        %   prop_names, prefixes)
        Clip = bml.oop.CodeClip;
        
        if ~exist('prefixes', 'var')
            prefixes = {'get', 'set'}; 
        elseif ischar(prefixes)
            prefixes = {prefixes};
        end
        
        if ischar(prop_names)
            prop_names = {prop_names};
        end 

        c = Clip.getsetfun_delegate(obj_name, delegator_name, ...
            prop_names, prefixes, '.', '');
    end
    function c = getsetfun_delegate(obj_name, delegator_name, ...
            prop_names, prefixes, connector_obj, connector_delegate)
        % getsetfun_delegate(obj_name, prop_names, prefixes={'get'})
        %
        % function v = get.prop(obj)
        %     v = obj.get_prop
        % end
        %
        % function set.prop(obj, v)
        %     obj.set_prop(v)
        % end
        Clip = bml.oop.CodeClip;
        
        if ~exist('prefixes', 'var')
            prefixes = {'get', 'set'}; 
        elseif ischar(prefixes)
            prefixes = {prefixes};
        end
        n_prefix = numel(prefixes);
        
        if ~exist('connector_obj', 'var')
            connector_obj = '_';
        end
        if ~exist('connector_delegate', 'var')
            connector_delegate = '_';
        end
        
        if ischar(prop_names)
            prop_names = {prop_names};
        end 

        c = '';
        for ii = 1:numel(prop_names)
            prop_name = prop_names{ii};

            for i_prefix = 1:numel(prefixes)
                prefix = prefixes{i_prefix};
                if isempty(connector_obj)
                    prefix_obj = '';
                else
                    prefix_obj = [prefix, connector_obj];
                end
                if isempty(connector_delegate)
                    prefix_delegate = '';
                else
                    prefix_delegate = [prefix, connector_delegate];
                end
                
                c = [c, Clip.getsetfun_delegate_text( ...
                    prefix_obj, prefix_delegate, obj_name, ...
                    delegator_name, prop_name)]; %#ok<AGROW>
            end
            if n_prefix > 1
                c = [c, sprintf('\n')]; %#ok<AGROW>
            end
        end
        Clip.show_and_copy(c);        
    end
    function c = getsetfun_and_dep(obj_name, prop_names, prefixes)
        Clip = bml.oop.CodeClip;
        
        if ~exist('prefixes', 'var')
            prefixes = {'get', 'set'};
        end
        
        c = sprintf('%s\n%s', ...
            Clip.getsetfun_dep(obj_name, prop_names, prefixes), ...
            Clip.getsetfun(obj_name, prop_names, prefixes));
        
        Clip.show_and_copy(c);
    end
    function c = getsetfun_dep(obj_name, prop_names, prefixes)
        % getsetfun_dep(obj_name, prop_names, prefixes={'get'})
        %
        % function v = get.prop(obj)
        %     v = obj.get_prop
        % end
        %
        % function set.prop(obj, v)
        %     obj.set_prop(v)
        % end
        Clip = bml.oop.CodeClip;
        
        if ~exist('prefixes', 'var')
            prefixes = {'get'}; 
        elseif ischar(prefixes)
            prefixes = {prefixes};
        end
        n_prefix = numel(prefixes);
        
        if ischar(prop_names)
            prop_names = {prop_names};
        end 

        c = '';
        for ii = 1:numel(prop_names)
            prop_name = prop_names{ii};

            for i_prefix = 1:numel(prefixes)
                prefix = prefixes{i_prefix};
                c = [c, Clip.getsetfun_dep_text(prefix, obj_name, prop_name)]; %#ok<AGROW>
            end
            if n_prefix > 1
                c = [c, sprintf('\n')]; %#ok<AGROW>
            end
        end
        Clip.show_and_copy(c);        
    end
    function c = getsetfun(obj_name, prop_names, prefixes)
        % Copies to clipboard the get/set functions for the property.
        %
        % getsetfun(obj_name, prop_names, prefixes={'set', 'get'})
        %
        % EXAMPLE:
        % CodeClip.getsetfun('Ev', {'ch'}, {'get', 'set'})
        % function v = get_ch(Ev)
        %     v = Ev.ch;
        % end
        % function set_ch(Ev, v)
        %     Ev.ch = v;
        % end     
        
        Clip = bml.oop.CodeClip;
        
        if ~exist('prefixes', 'var')
            prefixes = {'set', 'get'}; 
        elseif ischar(prefixes)
            prefixes = {prefixes};
        end
        n_prefix = numel(prefixes);
        
        if ischar(prop_names)
            prop_names = {prop_names};
        end 

        c = '';
        for ii = 1:numel(prop_names)
            prop_name = prop_names{ii};

            for i_prefix = 1:numel(prefixes)
                prefix = [prefixes{i_prefix} '_'];
                c = [c, Clip.getsetfun_text(prefix, obj_name, prop_name)]; %#ok<AGROW>
            end
            if n_prefix > 1
                c = [c, '\n']; %#ok<AGROW>
            end
        end
        Clip.show_and_copy(c);
    end
    function metaget(obj_name, metaget, prop_names)
        if ischar(prop_names)
            prop_names = {prop_names};
        end 

        c = '';
        for ii = 1:numel(prop_names)
            prop_name = prop_names{ii};
            
            c = [c, sprintf([ ...
                'function v = get_%2$s(%1$s)\n' ...
                '    v = %1$s.%3$s(''%2$s'');\n' ...
                'end\n' ...
                ], obj_name, prop_name, metaget)];
        end
        bml.oop.CodeClip.show_and_copy(c);
    end
end
%% Text handling
methods (Static, Hidden)
    function c = getsetfun_text(prefix, obj_name, prop_name)
        if strcmpStart('set', prefix)
            c = sprintf([ ...
            'function %3$s%2$s(%1$s, v)\n' ...
            '    %1$s.%2$s_ = v;\n' ...
            'end\n' ...
            ], obj_name, prop_name, prefix);
        elseif strcmpStart('get', prefix)
            c = sprintf([ ...
                'function v = %3$s%2$s(%1$s)\n' ...
                '    v = %1$s.%2$s_;\n' ...
                'end\n' ...
                ], obj_name, prop_name, prefix);
        else
            error('prefix must start with set or get!');
        end
    end
    function c = getsetfun_delegate_text(prefix_obj, prefix_delegator, ...
            obj_name, delegator_name, prop_name)
        if strcmpStart('set', prefix_obj)
            if isempty(prefix_delegator)
                c = sprintf([ ...
                'function %3$s%2$s(%1$s, v)\n' ...
                '    %1$s.%4$s.%2$s = v;\n' ...
                'end\n' ...
                ], obj_name, prop_name, prefix_obj, ...
                    delegator_name);
            else
                c = sprintf([ ...
                'function %3$s%2$s(%1$s, v)\n' ...
                '    %1$s.%4$s.%5$s%2$s(v);\n' ...
                'end\n' ...
                ], obj_name, prop_name, prefix_obj, ...
                    delegator_name, prefix_delegator);
            end
        elseif strcmpStart('get', prefix_obj)
            if isempty(prefix_delegator)
                c = sprintf([ ...
                    'function v = %3$s%2$s(%1$s)\n' ...
                    '    v = %1$s.%4$s.%2$s;\n' ...
                    'end\n' ...
                    ], obj_name, prop_name, prefix_obj, ...
                    delegator_name);
            else
                c = sprintf([ ...
                    'function v = %3$s%2$s(%1$s)\n' ...
                    '    v = %1$s.%4$s.%5$s%2$s();\n' ...
                    'end\n' ...
                    ], obj_name, prop_name, prefix_obj, ...
                    delegator_name, prefix_delegator);
            end
        else
            error('prefix must start with set or get!');
        end
    end
    function c = getsetfun_dep_text(prefix, obj_name, prop_name)
        if strcmp('set', prefix)
            c = sprintf([ ...
            'function set.%2$s(%1$s, v)\n' ...
            '    %1$s.set_%2$s(v);\n' ...
            'end\n' ...
            ], obj_name, prop_name);
        elseif strcmp('get', prefix)
            c = sprintf([ ...
                'function v = get.%2$s(%1$s)\n' ...
                '    v = %1$s.get_%2$s;\n' ...
                'end\n' ...
                ], obj_name, prop_name);
        else
            error('prefix must be set or get!');
        end
    end
    function show_and_copy(c)
        fprintf(c);
        clipboard('copy', sprintf(c));
    end
end
end