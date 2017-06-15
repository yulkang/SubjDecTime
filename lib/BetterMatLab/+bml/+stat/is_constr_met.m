function [all_met, met, v] = is_constr_met(x, lb, ub, A, b, Aeq, beq, nonlcon)
% Tests if all constraints are met.
%
% [all_met, met] = is_constr_met(x, lb, ub, A, b, Aeq, beq, nonlcon)
%
% x: parameter vector.
% lb, ub: vectors of the same length as x. Leave empty to skip.
% A, b, Aeq, beq, nonlcon: as from fmincon. Leave empty to skip.
%
% all_met: scalar logical.
% met: struct of logical fields.
% v: struct of values.

% 2016 Yul Kang. hk2699 at columbia dot edu.

all_met = true;

assert(isrow(x));
n = length(x);

if ~exist('lb', 'var') || isempty(lb)
    lb = -inf + zeros(1, n);
else
    assert(isrow(lb));
    assert(length(lb) == n);
end

if ~exist('ub', 'var') || isempty(ub)
    ub = +inf + zeros(1, n);
else
    assert(isrow(ub));
    assert(length(ub) == n);
end
if ~exist('A', 'var'), A = []; end
if ~exist('b', 'var'), b = []; end
if ~exist('Aeq', 'var'), Aeq = []; end
if ~exist('beq', 'var'), beq = []; end
if ~exist('nonlcon', 'var'), nonlcon = []; end

v.lb = lb - x;
met.lb = x >= lb;
all_met = all_met && all(met.lb);

v.ub = x - ub;
met.ub = x <= ub;
all_met = all_met && all(met.ub);

if ~isempty(A)
    v.Ab = A * x' - b(:);
    met.Ab = v.Ab <= 0;
    all_met = all_met && all(met.Ab);
else
    v.Ab = [];
    met.Ab = [];
end

if ~isempty(Aeq)
    v.Abeq = Aeq * x' - beq(:);
    met.Abeq = v.Abeq == 0;
    all_met = all_met && all(met.Abeq);
else
    v.Abeq = [];
    met.Abeq = [];
end

if ~isempty(nonlcon)
    v_nonlcon = nonlcon(x);
    v.c = v_nonlcon(1);
    v.ceq = v_nonlcon(2);
    met.c = v.c <= 0;
    met.ceq = v.ceq == 0;
    all_met = all_met && met.c && met.ceq;
else
    v.c = [];
    v.ceq = [];
    met.c = [];
    met.ceq = [];
end
