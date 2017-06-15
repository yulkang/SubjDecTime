function G = logisticGuess(ev, nResp, nResp2)

nResp1          = nResp - nResp2;

discEv          = discretize(ev, 6);

% bias
G.bias          = 0;
G.biasMin       = -median(ev(nResp1));
G.biasMax       =  median(ev(nResp2));

% miss
nMissTrials     = sum(nResp2(discEv == 1) + nResp1(discEv == 6));

pCorrect        = sum(nResp1(ev<0) + nResp2(ev>0)) / sum(nResp);

G.miss          = nMisTrials / sum(nResp);
G.missMin       = 0;
G.missMax       = min(1, (1-pCorrect)*2); % guess that every wrong choice was due to miss

G.missBias      = sum(nResp2(discEv == 1)) / nMissTrials;
G.missBiasMin   = 0;
G.missBiasMax   = 1;

% kPerSig
G.kPerSig       = 