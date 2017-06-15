function res = boot_strat(fun, arg_orig, sep, varargin)
S = varargin2S(varargin, {
    'seeds', []
    'n_sim', 1000
    });

if isempty(S.seeds)
    S.seeds = rand2seed(rand(S.n_sim, 1));
elseif isscalar(S.seeds)
    rng(S.seeds);
    S.seeds = rand2seed(rand(S.n_sim, 1));
else
    S.seeds = S.seeds(:);
end

n = size(arg_orig, 1);

if nargin < 3 || isempty(sep)
    sep = ones(n,1);
else
    [~,~,sep] = uniquetol(sep, 1e-5);
    n_sep = max(sep);
end

for ii = S.n_sim:-1:1
    rng(S.seeds(ii));
    ix_samp = zeros(n, 1);
    
    for jj = 1:n_sep
        ix_sep = find(sep == jj);
        n_in_sep = length(ix_sep);
        
        c_samp = randi(n_in_sep, [n_in_sep, 1]);
        
        ix_samp(ix_sep) = ix_sep(c_samp);
    end
    
    res(ii,1) = fun(arg_orig(ix_samp,:));
end