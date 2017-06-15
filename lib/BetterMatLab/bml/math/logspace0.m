function v = logspace0(st, en, n, base)
if nargin < 4, base = 2; end

if st < 0
    if mod(n,2) == 0
        v = logspace0(en/base^(n/2), en, n/2, base);
        v = [-fliplr(v), v];
    else
        v = union(0, logspace0(st, en, n-1, base));
    end
elseif st == 0
    cSt = en / (base^(n-1));
    
    v = [0, logspace0(cSt, en, n-1, base)];
else
    v = base .^ linspace(log(st)/log(base), log(en)/log(base), n);
end 
    
