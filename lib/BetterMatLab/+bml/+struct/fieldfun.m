function S = fieldfun(fun, S, fields)
% S = fieldfun(fun, S, fields)
if ~exist('fields', 'var')
    fields = fieldnames(S);
end
for f = fields(:)'
    S.(f{1}) = fun(S.(f{1}));
end