classdef DimProp < DeepCopyable
properties (SetAccess = protected)
    a
    obj
end
properties (Dependent)
    sizes
end
methods
    function Dims = DimProp(varargin)
        Dims.add_deep_copy({'a', 'obj'});
        Dims.a = struct;
        
        if nargin > 0
            Dims.init(varargin{:});
        end
    end
    function init(Dims, obj, props)
        % init(Dims, obj, props)
        % props : {prop1, dims1; prop2, dims2; ...}
        if ~isempty(obj)
            Dims.obj = obj;
        end
        assert(iscell(props));
        assert(ismatrix(props));
        assert(size(props, 2) == 2);
        
        n_prop = size(props, 1);
        
        for i_prop = 1:n_prop
            prop = props{i_prop, 1};
            dims = props{i_prop, 2};
            
            if isa(dims, 'DimInfo')
                Dims.a.(prop) = dims;
            else
                Dims.a.(prop) = Dim(dims);
            end
        end
    end
    function siz = get_size(Dims, prop)
        siz = Dims.a.(prop).get_size(Dims.obj);
    end
    function tf = check_size(Dims, prop)
        % tf = check_size(Dims, prop)
        size_prop = size(Dims.obj.(prop));
        size_info = Dims.get_size(prop);
        
        tf0 = length(size_prop) == length(size_info);
        if tf0
            is_specified = ~isnan(size_info);
            
            tf0 = tf0 && isequal( ...
                size_prop(is_specified), ...
                size_info(is_specified));
        end
        
        if nargout > 0
            tf = tf0;
        else
            assert(tf0);
        end
    end
end
%% Get/Set
methods
    function v = get_names(Dims)
        v = fieldnames(Dims.a)';
    end
    function v = get.sizes(Dims)
        v = Dims.get_sizes;
    end
    function v = get_sizes(Dims)
        v = struct;
        names = Dims.get_names;
        
        for name = names
            v.(name{1}) = Dims.get_size(name{1});
        end
    end
end
%% Demo
methods (Static)
    function Dims = demo
        %%
        Dim1 = DimInfo({
            't', []
            'cond', 2
            'ch', 3
            });
        
        Dim2 = DimInfo({
            'n', @(obj) numel(obj.a.Dim1.get_names)
            'dummy', []
            });
        
        Dims = DimProp;
        Dims.init(Dims, {
            'Dim1', Dim1
            'Dim2', Dim2
            });
        
        disp(Dims.sizes);
        assert(isequal_nan(Dims.sizes.Dim1, [nan, 2, 3]));
        assert(isequal_nan(Dims.sizes.Dim2, [3, nan]));
        
        disp('Passed tests!');
    end
end
end
    