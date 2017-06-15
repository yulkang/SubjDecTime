function ccue = beep2beepsweeps(ccue)
    cdurs = ccue.durs;

    ccue.n       = ccue.nBeep - 1;
    try
        ccue.freqs = [ccue.stfreqs(:), ccue.enfreqs(:)];
    catch
        ccue.freqs = [ccue.freqs(:)/2, ccue.freqs(:)];
    end
    ccue.offset  = 0.01 + cdurs(1);
    ccue.durs    = rep2fit(ccue.delays, [1, ccue.n]);
    ccue.delays  = rep2fit(cdurs,       [1, ccue.n - 1]);
    ccue.kind    = 'sweeps';
end
