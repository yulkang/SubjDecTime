classdef test_Fit_module_bias < Fit_module
    methods
        function me = test_Fit_module_bias
            me = me@Fit_module( ...
                {'x_scale', {0, -1, 1}});
        end
        
        function P = pred(~, fl)
            fl.P.x = fl.P.x * fl.th.x_scale;
            
            if nargout > 0, P = fl.P; end
        end
    end
end