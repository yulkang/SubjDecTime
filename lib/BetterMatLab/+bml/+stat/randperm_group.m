function v = randperm_group(gr)
% v = randperm_group(gr)
%
% EXAMPLE:
% bml.stat.randperm_group([1 1 1 2 2 2]')
%
% 2016 Yul Kang. hk2699 at columbia dot edu.

[~, ~, g] = unique(gr, 'rows');
ng = max(g);

n = size(gr, 1);
v = zeros(n, 1);

for ig = 1:ng
    incl = find(g == ig);
    n_incl = length(incl);
    
    v(incl) = incl(randperm(n_incl));
end