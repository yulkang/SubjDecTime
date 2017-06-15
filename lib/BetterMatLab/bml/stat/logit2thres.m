function [thres, spe, bnd_thres, bnd_spe] = logit2thres(b, pThres, covb)
% [thres, spe] = logit2thres(b, [pThres = 0.75, covb])
%
% b : 2-vector, as returned from glmfit with a logistic model.
%
% thres : Threshold.
% spe : Subjective point of equivalence. Always scalar.
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
if ~exist('pThres', 'var') || isempty(pThres), pThres = 0.75; end

if iscolumn(b)
    b = b';
end
spe = -b(:,1) ./ b(:,2);
thres = (logit(pThres) - b(:,1)) ./ b(:,2) - spe;

if exist('covb', 'var')
    assert(numel(b) == 2);
    n = 1e4;
    
    r = mvnrnd([b(1), b(2)], covb, n);
    
    [thres_samp, spe_samp] = bml.stat.logit2thres(r, pThres);
    
    p_ci = normcdf([-1, 1]) * 100;
    
    bnd_thres = prctile(thres_samp, p_ci);
    bnd_spe = prctile(spe_samp, p_ci);
end