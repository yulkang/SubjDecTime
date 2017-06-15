function ccue = beep2sweep(ccue)
    ccue.n       = ccue.nBeep - 1;
    ccue.freqs   = [ccue.freqs(:)/2, ccue.freqs(:)];
    ccue.durs    = rep2fit(ccue.durs, [1, ccue.n]) + rep2fit(ccue.delays, [1, ccue.n]);
    ccue.delays  = zeros(size(ccue.delays));
    ccue.kind    = 'sweeps';
end
