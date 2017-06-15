classdef FminconReduceExtensible < FminconReduce
    % Uses regular (rather than static) methods for extensibility.
    %
    % Regular methods are named get_* after the static counterpart *.
    %
    % !!!!!!!!!!!!!!!!!! TEST BEFORE USE !!!!!!!!!!!!!!!!!!!!
    
    % Perhaps UNNECESSARY since Test.fmincon_scale doesn't show any
    % effect of scale.
%
% 2015 (c) Yul Kang. yul dot kang dot on at gmail dot com.
properties
    x0
    A
    b
    Aeq
    beq
    lb
    ub
    opt
end
properties (Transient)
    % Don't save fun or nonlcon becuase saving function handles can
    % inflate file size.
    fun
    nonlcon
end
methods
    function F = FminconReduceExtensible(varargin)
        varargin2props(F, varargin, false);
    end
end
methods (Static)
    function varargout = fmincon(varargin)
        % Output changed from non-extensible
        F = FminconReduceExtensible.args2F(varargin{:});
        C = F.get_replace_args;
        [varargout{1:nargout}] = fmincon(C{:});
%             fun2, x02, A2, b2, Aeq2, beq2, lb2, ub2, nonlcon2, opt);

        % Input changed from non-extensible
        [varargout{1:nargout}] = ...
            F.get_replace_outputs(varargout{:});
    end
end
methods (Static)
    function F = args2F(varargin)
        assert(length(varargin) >= 2, 'Give fun and x0, at least!');
        [fun, x0, A, b, Aeq, beq, lb, ub, nonlcon, opt] = ...
            dealDef(varargin, {}, true);
        
        if isempty(lb)
            lb = -inf(size(x0)); 
        end
        if isempty(ub)
            ub = inf(size(x0)); 
        end
        
        C = S2C(packStruct(fun, x0, A, b, Aeq, beq, lb, ub, nonlcon, opt));
        F = FminconReduceExtensible(C{:});
    end
end
methods
    function C = get_args_original(F)
        C = {F.fun, F.x0, F.A, F.b, F.Aeq, F.beq, F.lb, F.ub, ...
             F.nonlcon, F.opt};
    end
    function C = get_replace_args(F)
        % Before, didn't use F in function handle, so that it works after
        % converting to string and back.
        % But that may not be true. x0 and to_fix are not recovered either.
        % Perhaps better to save F (which is lightweight) and 
        % recover in lieu of it (or save without conversion to string).
        fun2 = @(v) F.fun(F.get_x_vec_all(v));
        
        to_fix = F.get_to_fix;
        x02  = F.x0(~to_fix);

        % Empty defaults
        A2 = [];
        b2 = [];
        Aeq2 = [];
        beq2 = [];
        lb2 = [];
        ub2 = [];
        nonlcon2 = [];

        % Work on each output
        if ~isempty(F.A)
            [A2, b2] = F.reduce_constr(F.A, F.b, F.x0, to_fix, ...
                @(Ax,b) Ax <= b);
        end
        if ~isempty(F.Aeq)
            [Aeq2, beq2] = F.reduce_constr(F.Aeq, F.beq, F.x0, to_fix, ...
                @(Ax,b) Ax == b);
        end
        if ~isempty(F.lb)
            lb2 = F.lb(~to_fix);
        end
        if ~isempty(F.ub)
            ub2 = F.ub(~to_fix);
        end
        if ~isempty(F.nonlcon)
            nonlcon2 = @(v) F.nonlcon(F.get_fill_vec(v));
        end       
        
        C = {fun2, x02, A2, b2, Aeq2, beq2, lb2, ub2, nonlcon2, F.opt};
    end
    
    % Input changed from non-extensible
    function varargout = get_replace_outputs(F, varargin)
        varargout = varargin;
        x0 = F.x0;
        
        if nargout >= 1
            % x
            varargout{1} = F.get_fill_vec(x0, varargout{1});
        end
        if nargout >= 6
            % gradient
            varargout{6} = F.fill_vec(zeros(size(F.x0)), ...
                F.get_to_fix, varargout{6});
        end
        if nargout >= 7
            % Hessian
            if isempty(varargout{7})
                varargout{7} = nan(length(x0));
            else
                varargout{7} = F.fill_mat(varargout{7}, F.get_to_fix, inf);
            end
        end
        % TODO: add get_se
    end
end
methods % Regular counterparts of the static functions
    function v = get_x_vec_all(F, x_vary)
        v = F.get_fill_vec(F.x0, x_vary);
    end
    function v = get_to_fix(F)
        v = isequal_mat_nan(F.lb, F.ub);
    end
    function v = get_fill_vec(F, x0, x_vary)
        v = F.fill_vec(x0, F.get_to_fix, x_vary);
    end
end
end  