function v = normalize(v, dim)
% Return Z-scores, i.e., subtract mean and divide by standard deviation.
%
% v = normalize(v, dim=1)

if ~exist('dim', 'var'), dim = 1; end

v = bsxfun(@minus,   v, mean(v, dim));
v = bsxfun(@rdivide, v, std(v,0,dim)); 

% Should I normalize by N-1 (as in std(..,0,..)) or by N? (std(..,1,..))
% Perhaps N-1, since what we have is only a sample, not the population.