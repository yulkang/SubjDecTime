classdef handleValue < matlab.mixin.Copyable
    % A wrapper that allows passing handles to a value.
    properties
        v
    end
    
    methods
        function h = handleValue(v)
            h.v = v;
        end
    end
end