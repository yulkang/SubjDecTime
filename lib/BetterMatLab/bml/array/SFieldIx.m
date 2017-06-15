function res = SFieldIx(S, ix)
% res = SFieldIx(S, ix)

f = fieldnames(S);

res = S.(f{ix});