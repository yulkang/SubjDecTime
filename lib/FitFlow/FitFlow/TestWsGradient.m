classdef TestWsGradient < FitWorkspace
properties
    target = 6:-1:2;
    target_grad = 6:-1:2; % 2:6;
end
methods
    function W = TestWsGradient(varargin)
        W.init_params0;
    end
    function init_params0(W)
        n = numel(W.target);
        W.add_params({
            {'vec', 1:n, zeros(1,n), 10 + zeros(1,n)}
            });
    end
    function [cost, grad] = get_cost(W)
        cost = sum((W.th.vec - W.target) .^ 2);
        grad = 2 .* (W.th.vec - W.target_grad);
        
        W.th_grad_vec = grad;
        
        disp(W.th_vec);
        
        disp(nargout);
        disp('cost');
    end
    function [Fl, res] = fit(W, varargin)
        % [Fl, res] = fit(W, varargin)
        %
        % A template for fitting functions.
        % See also: FitFlow.fit_grid
        
        S = varargin2S(varargin, {
            'opts', {}
            });
        S.opts = varargin2S(S.opts, {
            'UseParallel', false
            'SpecifyObjectiveGradient',true
            });
        
        Fl = W.get_Fl;
        C = S2C(S);
        res = Fl.fit(C{:});
    end
    function Fl = get_Fl(W)
        Fl = W.get_Fl@FitWorkspace;
        Fl.specify_grad = true;
    end
end
end