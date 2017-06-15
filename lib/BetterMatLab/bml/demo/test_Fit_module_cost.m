classdef test_Fit_module_cost < Fit_module
    methods
        function me = test_Fit_module_cost
            me = me@Fit_module( ...
                {'x', {2, 1, 3}, ...
                 'y', {20, 10, 30}}, ...
                {'x', 'y'});
        end
        
        function c = cost(~, fl) % (~, ~, P, ~, th, dat)
            fl.c = sum((fl.dat.x - fl.P.x).^2 + (fl.dat.y - fl.th.y).^2);
            
            if nargout > 0, c = fl.c; end
        end
    end
end