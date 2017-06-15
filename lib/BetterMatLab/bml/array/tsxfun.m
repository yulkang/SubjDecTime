function res = tsxfun(a, op1, b, op2, c)
% res = tsxfun(a, op1, b, op2, c)

res = bsxfun(op2, bsxfun(op1, a, b), c);
end