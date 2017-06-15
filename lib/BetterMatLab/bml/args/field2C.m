function C = field2C(S, fs, args)
% Gives fields in a cell vector.
%
% field2C(S, fs) : {S.(fs{1}), S.(fs{2}), ...}
% field2C(S, fmt, args) : equivalent to field2C(S, csprintf(fmt, args))

if nargin >= 3
    if iscell(args)
        C = field2C(S, csprintf(fs, args{:}));
    else
        C = field2C(S, csprintf(fs, args));
    end
else
    n = length(fs);
    C = cell(1, n);
    for ii = 1:n
        C{ii} = S.(fs{ii});
    end
end