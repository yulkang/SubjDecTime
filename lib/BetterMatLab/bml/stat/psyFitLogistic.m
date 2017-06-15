function [negLogLikelihood, predP2] = psyFitLogistic(param, data)
coh		= data(:,1);
nResp	= data(:,2);
nResp2	= data(:,3);
nResp1	= nResp - nResp2;

[predP2]	= psyPredLogistic(coh, param);

% Likelihood of choice probability: see Gwangbae Park 2006, p. 274
negLogLikelihood = -sum( ...
	gammaln(nResp+1) - gammaln(nResp1+1) - gammaln(nResp2+1) ...
	+ nResp1.*log((1-predP2)+eps) + nResp2.*log(predP2+eps) ...
	);
return;
