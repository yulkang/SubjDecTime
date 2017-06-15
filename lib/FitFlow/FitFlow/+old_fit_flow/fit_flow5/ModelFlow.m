classdef ModelFlow < matlab.mixin.Copyable
    % Designed to accompany FitFlow5.
    
    properties
        Fl % All other settings are the model's own properties, to avoid cluttering.
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