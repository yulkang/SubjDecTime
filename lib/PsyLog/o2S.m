function S = o2S(o, S)
% S = o2S(o, S)

if nargin < 2, S = struct; end

for f = fieldnames(o)'
    o.(f{1}).tag = f{1};
    V = v2S(o.(f{1}));
    T = relSec(o.(f{1}));
    
    for v = fieldnames(V)'
        S.(['v_' f{1} '__' v{1}]) = V.(v{1});
    end
    for t = fieldnames(V)'
        S.(['relSec_' f{1} '__' t{1}]) = T.(t{1});
    end
end
end