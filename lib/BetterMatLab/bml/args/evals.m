function C = evals(C)
% EVALS  Evaluate each cell. If a function handle, return the value.
%
% C = evals(C)


n = length(C);

for ii = 1:n
    if isa(C{ii}, 'function_handle')
        C{ii} = C{ii}();
    end
end