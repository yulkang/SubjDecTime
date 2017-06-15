function sig = bonferroniholm(p, varargin)
% sig = bonferroniholm(p, varargin)
%
% 'alpha', 0.05
%
% 2016 Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'alpha', 0.05
    });

m = numel(p);
[p1, ix] = sort(p(:));

lev = S.alpha ./ (m + 1 - (1:m)');
k = find(p1 > lev, 1, 'first');
if isempty(k)
    k = (m + 1);
end

sig = false(size(p));
sig(ix(1:(k-1))) = true;
end

function test_bonferroniholm
%%
p1 = 0.049;
p0 = 0.051;

f = @(p, m, k) p ./ (m + 1 - k);
f_all = @(p, m) f(p, m, 1:m);
f_all2 = @(p, m) f(p, m, m:-1:1);

sig = bml.stat.bonferroniholm(p0)
sig = bml.stat.bonferroniholm(p1)

%%
p0s = f_all(p0, 5)
sig = bml.stat.bonferroniholm(p0s)

%%
p1s = f_all(p1, 5)
sig = bml.stat.bonferroniholm(p1s)

%%
p0s = f_all2(p0, 5)
sig = bml.stat.bonferroniholm(p0s)

%%
p1s = f_all2(p1, 5)
sig = bml.stat.bonferroniholm(p1s)
end