classdef ModelFlow < matlab.mixin.Copyable
    properties
        Fl
    end
    
    methods
        function Fl = init(Fl)
        end
        function res = fit(Fl)
        end
        function c = cost(Fl)
        end
    end
end