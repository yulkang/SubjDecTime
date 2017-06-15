classdef ObjSaver
methods (Static)
    function [S, info, opt] = obj2struct(obj, varargin)
        % Copy object to struct without handle properties, 
        % suitable for saving.
        
        opt = varargin2S(varargin, {
            'skip_name', {}
            'skip_class', {}
            'max_depth', inf
            ...
            'copied', {}
            'depth', 0
            });
        
        [S, info] = bml.oop.copyprops(struct, obj, ...
            'skip_handle', true, ...
            'skip_internal', true);
        opt.copied{end+1} = obj;
        
        if opt.depth < opt.max_depth && isfield(info, 'handles')
            for name = fieldnames(info.handles)'
                skip_copy = false;
                prop = info.handles.(name{1});

                % Skip if copied already
                for ii = 1:length(opt.copied)
                    if opt.copied{ii} == prop
                        skip_copy = true;
                        break;
                    end
                end
                if skip_copy, continue; end
                
                % Skip based on name
                skip_copy = any(strcmp(name{1}, opt.skip_name));
                if skip_copy, continue; end
                
                % Skip internal properties (those that end with '_')
                if name{1}(end) == '_'
                    continue;
                end
                
                % Skip based on class
                for ii = 1:length(opt.skip_class)
                    if isa(prop, opt.skip_class{ii})
                        skip_copy = true;
                        break;
                    end
                end
                if skip_copy, continue; end

                % Copy
                C = varargin2C({
                    'depth', opt.depth + 1
                    }, opt);
                
                S.(name{1}) = bml.oop.ObjSaver.obj2struct( ...
                    prop, C{:}); 
            end
        end
    end
    function save_obj(file, L)
        % Saves a struct, converting object fields to structs.
        %
        % save_obj(file, L)
        for f = fieldnames(L)'
            if isa(L.(f{1}), 'handle')
                L.(f{1}) = bml.oop.ObjSaver.obj2struct(L.(f{1}));
            end
        end
        save(file, '-struct', 'L');
    end
end
end