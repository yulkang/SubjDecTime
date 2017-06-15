classdef FitFlow6 < FitFlow5
% Uses FitWorkspace as W and W0.
% Fl.init and Fl.get_cost will interface Fl.W.init_bef_fit and Fl.W.get_cost.

methods
    function Fl = FitFlow6(varargin)
        Fl = Fl@FitFlow5;
        Fl.VERSION = 6;
        Fl.VERSION_DESCRIPTION = 'Uses FitWorkspace as W and W0.';
        Fl.W0 = FitWorkspace;
        Fl.W  = FitWorkspace;
        Fl = varargin2fields(Fl, varargin);
    end
    function Fl = init(Fl, varargin)
        % Set properties of Fl, and copies W0 to W, and invokes Fl.W.init_bef_fit.
        % Use after Fl.set_W0.
        %
        % Fl = init(Fl, Fl_args, ..., 'W_args', {W_args, ...})
        
        S = varargin2S(varargin, {
            'W_args',  {}
            });
        
        % Set properties of Fl
        Fl_C = varargin2C(rmfield(S, 'W_args'));
        Fl = varargin2fields(Fl, Fl_C{:});
        
        % Copy W0 to W
        assert(isa(Fl.W0, 'FitWorkspace'), 'Use init() after set_W0() !');
        Fl.set_W(copy(Fl.W0));
        
        % Invoke Fl.W.init_bef_fit
        W_C = varargin2C(S.W_args);
        [Fl.W, Fl] = init(Fl.W, Fl, W_C{:});
        
        % add_th should be called from W.init_bef_fit, and
        % W should have corresponding public properties.
    end
    function run_init(Fl, varargin)
        % Invokes Fl.W.init_bef_fit()
        Fl.W.init_bef_fit(Fl, varargin{:});
    end
    function c = run_iter(Fl, varargin)
        % Invokes Fl.W.get_cost()
        c = Fl.W.get_cost(Fl, Fl.th_vec, varargin{:});
    end
    function c = run(Fl, varargin)
        % c = run(Fl, 'init_args, {...}, 'iter_args', {...})
        S = varargin2S(varargin, {
            'init_args', {}
            'iter_args', {}
            });
        
        Fl.run_init(S.init_args{:});
        c = Fl.run_iter(S.iter_args{:});
    end
    function f = cost_fun(Fl, op)
        % Fed to optimizer.
        %
        % c = cost_fun(Fl, th_vec, varargin)
        
        if nargin < 2, op = 'iter'; end
        assert(any(strcmp(op, {'init', 'iter'})));
        
        switch op
            case 'init'
                f = @(varargin) Fl.W.init_bef_fit(varargin{:});
            case 'iter'
                f = @(th_vec, varargin) Fl.W.get_cost(th_vec, Fl, varargin{:});
        end
    end
    
    %% Deprecated
    function varargout = calc_cost(varargin)
        error('Deprecated. Use cost_fun instead!');
    end
    
    %% Get/Set
    function Fl = set_W(Fl, W)
        assert(isa(W, 'FitWorkspace'));
        Fl.W = W;
    end
    function Fl = set_W0(Fl, W0)
        assert(isa(W0, 'FitWorkspace'));
        Fl.W0 = W0;
    end
    function c = get_cost(Fl, varargin)
        % Invokes Fl.W.get_cost()
        c = Fl.W.get_cost(Fl.th_vec, Fl, varargin{:});
        Fl.cost = c;
    end
end
end