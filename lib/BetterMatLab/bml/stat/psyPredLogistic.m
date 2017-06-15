function [predPResp2] = psyPredLogistic(coh, param)
% function [predPResp1] = psyPredLogistic(coh, param)
% Shadlen 2006, eq. 10.23, 25, 34-36
%
% param = [kPerSig, bias, miss, guess2]
%
% kPerSig   : k/sigma, or signal-to-noise ratio of integration.
% bias      : Difference between effective and actual evidence.
% miss      : Proportion of trials where the evidence is completely ignored.
% guess2    : Proportion of choice 2 on miss. Defaults to 0.5

kPerSig	= param(1);
bias	= param(2);
if length(param) < 3, miss   = 0;   else miss   = param(3); end
if length(param) < 4, guess2 = 0.5; else guess2 = param(4); end

C           = coh - bias;

% eq. 10.23 & 10.25
predPResp2  = (1./(1+exp(-kPerSig.*C))) .* (1-miss) ...
            + miss * guess2;
return;