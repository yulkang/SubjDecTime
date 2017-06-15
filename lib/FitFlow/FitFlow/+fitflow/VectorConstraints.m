classdef VectorConstraints < DeepCopyable
properties
    A
    b
    Aeq
    beq
    lb
    ub
    nonlcon
end
properties (Dependent)
    % fmincon_constr
    % = {A, b, Aeq, beq, lb, ub, nonlcon}
    % : Feed fmincon with fmincon(fun, x0, Constr.fmincon_constr{:});
    fmincon_constr
    
    % bnd_constr
    % = {lb, ub, A, b, Aeq, beq, nonlcon}
    % : Similar to fmincon_constr but lb and ub come first.
    bnd_constr
    
    % typical_scale:
    % When lb <= 0 <= ub, the typical scale is mean(abs([lb, ub]))
    % When 0 <= lb <= ub, it is mean([lb, ub])
    % When lb <= ub <= 0, it is also mean([lb, ub]), which is negative.
    % When lb and ub have different lengths, the unmatched elements are NaN.
    typical_scale
end
methods
    function Constr = VectorConstraints(varargin)
        % Constr = VectorConstraints('property1', value1, ...)
        % Constr = VectorConstraints({lb, ub, A, b, Aeq, beq, nonlcon}, ...)
        if nargin > 0
            Constr.init(varargin{:});
        end
    end
    function init(Constr, varargin)
        if iscell(varargin{1})
            Constr.bnd_constr = varargin{1};
            varargin = varargin(2:end);
        end
        bml.oop.varargin2props(Constr, varargin); % , true);
    end
    function [all_met, met, v] = is_constr_met(Constr, th)
        % See also: bml.stat.is_constr_met
        [all_met, met, v] = bml.stat.is_constr_met(th, ...
            Constr.lb, Constr.ub, ...
            Constr.A, Constr.b, Constr.Aeq, Constr.beq, ...
            Constr.nonlcon);
    end
end
%% Get/Set
methods
    function C = get.fmincon_constr(Constr)
        C = {Constr.A, Constr.b, Constr.Aeq, Constr.beq, ...
            Constr.lb, Constr.ub, Constr.nonlcon};
    end
    function C = get.bnd_constr(Constr)
        C = {Constr.lb, Constr.ub, ...
            Constr.A, Constr.b, Constr.Aeq, Constr.beq, ...
            Constr.nonlcon};
    end
    function set.fmincon_constr(Constr, C)
        assert(iscell(C));
        if numel(C) >= 1, Constr.A = C{1}; end
        if numel(C) >= 2, Constr.b = C{2}(:); end
        if numel(C) >= 3, Constr.Aeq = C{3}; end
        if numel(C) >= 4, Constr.beq = C{4}(:); end
        if numel(C) >= 5, Constr.lb = C{5}; end
        if numel(C) >= 6, Constr.ub = C{6}; end
        if numel(C) >= 7, Constr.nonlcon = C{7}; end
    end
    function set.bnd_constr(Constr, C)
        assert(iscell(C));
        if numel(C) >= 1, Constr.lb = C{1}; end
        if numel(C) >= 2, Constr.ub = C{2}; end
        if numel(C) >= 3, Constr.A = C{3}; end
        if numel(C) >= 4, Constr.b = C{4}(:); end
        if numel(C) >= 5, Constr.Aeq = C{5}; end
        if numel(C) >= 6, Constr.beq = C{6}(:); end
        if numel(C) >= 7, Constr.nonlcon = C{7}; end
    end
    function v = get.typical_scale(Constr)
        % When lb <= 0 <= ub, the typical scale is mean(abs([lb, ub]))
        % When 0 <= lb <= ub, it is mean([lb, ub])
        % When lb <= ub <= 0, it is also mean([lb, ub]), which is negative.
        % When lb and ub have different lengths, the unmatched elements are NaN.
        
        lb = Constr.lb;
        ub = Constr.ub;
        
        len_lb = length(lb);
        len_ub = length(ub);
        if len_lb < len_ub
            n_dif = len_ub - len_lb;
            ub = ub(1:len_lb);
        elseif len_lb > len_ub
            n_dif = len_lb - len_ub;
            lb = lb(1:len_ub);
        else
            n_dif = 0;
        end
        
        if isempty(lb)
            v = [];
        else
            pos_only = lb >= 0;
            neg_only = ub <= 0;
            both = (~pos_only) & (~neg_only);

            dispersion = (ub - lb) ./ 4;
            middle = (ub + lb) ./ 2;

            v = ones(size(ub));

            v(pos_only | neg_only) = middle(pos_only | neg_only);
            v(both) = dispersion(both);
        end
        
        % Fill in
        v(end + (1:n_dif)) = nan;
    end
end
%% Reduce - when there are fixed parameters
methods
    function reduce(Constr, th_free)
        if ~exist('th_free', 'var')
            th_free = Constr.lb ~= Constr.ub;
        end
        
        assert(~isempty(Constr.lb));
        assert(~isempty(Constr.ub));        
        assert(isequal(Constr.lb(~th_free), Constr.ub(~th_free)));
        
        th_fixed = Constr.lb(~th_free);
        Constr0 = Constr.copy;

        Constr.lb = Constr.lb(th_free);
        Constr.ub = Constr.ub(th_free);
        
        if ~isempty(Constr.A)
            assert(~isempty(Constr.b));
            b_fixed = Constr.A(:, ~th_free) * th_fixed';
            
            Constr.A = Constr.A(:, th_free);
            Constr0.A(:,~th_free);

            Constr.b(:) = Constr.b(:) + b_fixed;
        end
        if ~isempty(Constr.Aeq)
            assert(~isempty(Constr.beq));
            b_fixed = Constr.Aeq(:, ~th_free) * th_fixed;
            
            Constr.Aeq = Constr.Aeq(:, th_free);
            Constr.beq(:) = Constr.beq(:) + b_fixed;
        end
        nonlcon = Constr.nonlcon;
        if ~isempty(nonlcon)
            Constr.nonlcon = @f_nonlcon;
        end
        function [c, ceq] = f_nonlcon(x)
            if ~isempty(nonlcon)
                x_all = zeros(size(th_free));
                x_all(~th_free) = Constr0.lb(~th_free);
                x_all(th_free) = x;
                
                [c, ceq] = nonlcon(x_all);
            else
                c = 0;
                ceq = 0;
            end
        end
    end
end
%% Demo
methods
    function demo(Constr)
        %%
        Constr.init( ...
            'Aeq', [1 1 0; 0 5 1], ...
            'beq', [2, 3]', ...
            'lb', [0 1 0], ...
            'ub', [10 1 10]);
        Constr.reduce;
        disp(Constr.A);
        disp(Constr.b);
        disp(Constr.Aeq);
        disp(Constr.beq);
        disp(Constr);
    end
end
end