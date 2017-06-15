function b = thres2logit(thres, spe, pThres)
% b = logit2thres(thres, spe, pThres = 0.75)
%
% thres : Threshold.
% spe : Subjective point of equivalence.
%
% b : 2-vector, as would be returned from simulation of a logistic model.
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.
if ~exist('pThres', 'var'), pThres = 0.75; end
assert(isscalar(pThres));

b(2) = logit(pThres) ./ thres;
b(1) = -b(2) ./ spe;
