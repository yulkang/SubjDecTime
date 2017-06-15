% test_butter

pass_freq  = 100;
samp_freq  = 1000; % 1/2 of this is Nyquist frequency.

ord_butter = 10;
filt_freq  = pass_freq/(samp_freq/2);

[z,p,k] = butter(ord_butter, filt_freq);
sos = zp2sos(z,p,k);
fvtool(sos, 'Analysis', 'freq');