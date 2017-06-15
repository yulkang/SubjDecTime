classdef MethodsView < matlab.mixin.Copyable
% View methods by their defining classes and superclasses.
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.
properties
    show_help = false; % true;
    max_level = 2;
    obj = [];
    rich_disp = true;
end
methods
    function View = MethodsView(obj, varargin)
        % View = MethodsView(obj, varargin)
        View.obj = obj;
        varargin2fields(View, varargin);
    end
    function disp(View)
        obj = View.obj;
        if ischar(obj)
            mc_obj = MethodsView.metaclass_by_name(obj);
        else
            mc_obj = metaclass(obj);
        end
        classes = mc_obj;
        
        for i_level = 1:View.max_level
            fprintf('===== Level %d =====\n', i_level);
            
            super_ = [];
            for i_class = 1:numel(classes)
                mc = classes(i_class);
                fprintf('----- %s -----\n', mc.Name);
                
                methods_ = mc.MethodList;
                for i_method = 1:numel(methods_)
                    method_ = methods_(i_method);

                    if mc == method_.DefiningClass
                        View.view_method(method_);
                    end 
                end
                direct_super_ = mc.SuperclassList;
                super_ = [super_(:)', direct_super_(:)'];
            end
            classes = super_;
            if isempty(classes), break; end
        end
    end
    function view_method(View, method_, obj)
        % view_method(View, method_, obj)
        name = method_.Name;
        defining_class = method_.DefiningClass.Name;
        
        [~, info] = methodsview(defining_class, 'noUI');
        info = cell(info);
        method_names = info(:,3);
        ix = strcmp(method_names, name);
        
        if ~any(ix)
            return; % Skip methods that are not shown on methodsview
        end
        
        attr = info{ix, 1};
        out  = info{ix, 2};
        in   = info{ix, 4};
        
        if ~isempty(attr)
            attr = ['(' attr ') '];
        end
        if ~isempty(out)
            out = [out ' = ']; 
        end
        if View.rich_disp && ~View.show_help
            name_disp = ['<strong>' name '</strong>'];
        else
            name_disp = name;
        end
        
%         fprintf('%s %s%s%s(%s)\n', defining_class, attr, out, name, in);
        s = sprintf('%s%s%s%s', attr, out, name_disp, in);
        if View.rich_disp && View.show_help
            disp(['<strong>' s '</strong>']);
%             fprintf('<strong>%s</strong>\n', s);
        else
            fprintf('%s\n', s);
        end
        if View.show_help
            fprintf('%s\n', help([defining_class '.' name]));
        end
    end
end
methods (Static)
    function mc = metaclass_by_name(name)
        % mc = metaclass_by_name(name)
        mc = eval(['? ' name]);
    end
end
end

