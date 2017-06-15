function S = renamefield(S, pairs)
% S = renamefield(S, pairs)

assert(size(pairs, 2) == 2);
assert(iscell(pairs));
n = size(pairs, 1);

src = pairs(:,1);
dst = pairs(:,2);

is_changed = false(n, 1);

for ii = 1:n
    if ~isfield(S, src{ii}), continue; end
    
    [S.(dst{ii})] = [S.(src{ii})];
    
    is_changed(ii) = ~strcmp(dst{ii}, src{ii});
end

S = rmfield(S, src(is_changed));