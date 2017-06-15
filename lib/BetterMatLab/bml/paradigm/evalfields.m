function P = evalfields(Ps, skipfields)
% Evaluate fields.
% Can refer to previously evaluated fields as P.(field)
%
% P = evalfields(Ps, skipfields)

if nargin < 2, skipfields = {'choice_'}; end % See paramSelector for why

fs = setdiff(fieldnames(Ps)', skipfields, 'stable');
P  = struct;

for f = fs
    try
        P.(f{1}) = eval(Ps.(f{1}));
    catch err
        fprintf('Error evaluating Ps.%s : %s\n', f{1}, Ps.(f{1}));
        rethrow(err);
    end
end