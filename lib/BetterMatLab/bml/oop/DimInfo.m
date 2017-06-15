classdef DimInfo < DeepCopyable
properties (SetAccess = protected)
    dim
    size_fun
end
methods
    function Dim = DimInfo(varargin)
        if nargin > 0
            Dim.init(varargin{:});
        end
    end
    function init(Dim, dims)
        % dims: {name1, size1; ...}
        %
        % size1 : empty, a scalar numeric, or a function handle.
        assert(iscell(dims));
        assert(ismatrix(dims));
        assert(size(dims, 2) == 2);
        n_dim = size(dims, 1);
        
        Dim.dim = struct;
        Dim.size_fun = struct;
        for i_dim = 1:n_dim
            name = dims{i_dim, 1};
            assert(ischar(name));
            Dim.dim.(name) = i_dim;
            
            info = dims{i_dim, 2};
            
            if isempty(info)
                Dim.size_fun.(name) = @(varargin) nan;
            elseif isa(info, 'function_handle');
                Dim.size_fun.(name) = info;
            elseif isnumeric(info)
                Dim.size_fun.(name) = @(varargin) info;
            end
        end
    end
end
%% Get/Set
methods
    function v = get_names(Dim)
        v = fieldnames(Dim.dim)';
    end
    function v = get_size(Dim, varargin)
        names = Dim.get_names;
        n_dim = length(names);
        
        v = zeros(1, n_dim);
        
        for dim = 1:n_dim
            name = names{dim};
            v(dim) = Dim.size_fun.(name)(varargin{:});
        end
    end
end
%% Demo
methods (Static)
    function Dim2 = demo
        %%
        Dim1 = DimInfo({
            't', []
            'cond', 2
            'ch', 3
            });
        disp(Dim1);
        
        Dim2 = DimInfo({
            'n', @(obj) numel(obj.get_names)
            'dummy', []
            });
        disp(Dim2.get_size(Dim1));
        assert(isequal_nan(Dim2.get_size(Dim1), [3, nan]));
        
        disp('Passed tests!');
    end
end
end
    