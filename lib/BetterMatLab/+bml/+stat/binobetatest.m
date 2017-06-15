function [est, pval] = binobetatest(a, b, varargin)
% [est, pval] = binobetatest(a, b)
% a: # success
% b: # failure
% est: maximum likelihood mean
% pval : two-tailed

S = varargin2S(varargin, {
    'est0', 0.5
    });

est = a ./ (a + b);
pval = ones(size(est));

lt = est < S.est0;
pval(lt) = (1 - betacdf(S.est0, a(lt), b(lt))) .* 2; 

rt = est > S.est0;
pval(rt) = betacdf(S.est0, a(rt), b(rt)) .* 2;

end