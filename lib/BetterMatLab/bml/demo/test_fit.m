function test_fit
test_cost = @(x) sum((x-2).^2);

[x, fval, exitflag, output, lambda, grad, hessian] = ...
    fmincon(test_cost, [1.5 .5], [], [], [], [], [-2 -2], [2 -2], ...
    @nonlin_constraint)
end

function [c, ceq] = nonlin_constraint(x)
    c = 0;
    ceq = x(1) * x(2) - 1;
end

