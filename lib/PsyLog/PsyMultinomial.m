classdef PsyMultinomial < handle
properties
    rStream
    
    fr = 0;
    n_fr = 120;
    
    n_lev     = [3 3];
    n_dim     = 2;
    dim_names
    
    % prob
    % : if indep_dims, = {1,n_dim} cell array of (1,n_lev(d)) matrices.
    % : if ~indep_dims, = (ndim+1) array: (1st dim x 2nd dim .. x time).
    prob 
    indep_dims = true;
    stationary_prob = true;
    history
    
    textures
end

methods
    function me = PsyMultinomial(varargin)
        if nargin > 0
            me.init(varargin{:});
        end
    end
    
    function init(me, varargin)
        varargin2fields(me, varargin);
        
        c_n_fr    = me.n_fr;
        c_n_dim   = me.n_dim;
        
        % Expand c_prob if necessary
        c_prob = me.prob;        
        if size(c_prob, c_n_dim + 1) == 1
            me.stationary_prob = true;
            c_prob = repmat(c_prob, [ones(1, c_n_dim), me.n_fr]);
        end
        
        % Sample instances from prob % TODO
        c_history = zeros(c_n_fr, c_n_dim);
        
        me.history = c_history;
        
%         for c_fr = 1:c_n_fr
%             % c_history(c_fr,:) = sample_ND(me.rStream, c_prob, c_n_dim);
%         end
    end
    
    function initLogTrial(me)
        me.fr = 0;
    end
    
    function res = draw(me, ~)
        % Text output for demo
        disp(me.history);
        
        res = true;
    end
end

methods (Static)
    function Multinomial = test(varargin)
        Multinomial = PsyMultinomial(varargin{:});
        
        Multinomial.draw;
    end
end
end