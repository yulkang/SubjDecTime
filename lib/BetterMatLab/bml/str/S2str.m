function s = S2str(S, F)
% Convert a non-nested struct to string efficiently

f = fieldnames(S)';
n = length(f);
c = cell(1, n);

for ii = 1:n
    switch class(S.(f{ii}))
        case {'double', 'single', 'int32'}
            c{ii} = sprintf('%s:[%s]\n', f{ii}, sprintf('%1.1f', S.(f{ii})));
        case {'char'}
            c{ii} = sprintf('%s:"%s"\n', f{ii}, S.(f{ii}));
    end
end

s = [c{:}];