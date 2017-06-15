function S = output2struct(fun, names, n_output)
% S = output2struct(fun, names, n_output)

if ~exist('n_output', 'var')
    n_output = length(names);
end

[outputs_C{1:n_output}] = fun();

S = cell2struct(outputs_C, names, 2);