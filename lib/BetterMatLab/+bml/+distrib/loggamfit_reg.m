function [logdat, m, s] = loggamfit_reg(freq)
% loggampdf fit of the observed frequencies in regularly spaced bins.
%
% [logdat, m, s] = loggamfit_reg(freq)
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

assert(isvector(freq));

sum0 = nansum(freq);
freq = freq ./ sum0;

n = length(freq);
ix0 = 1:n;
if iscolumn(freq), ix0 = ix0'; end

alpha = [];

thres = 1e-3;
ix_last = find(freq >= thres, 1, 'last');
ix = ix0(1:ix_last);

freq1 = freq ./ thres;

censoring = zeros(size(ix)); % ones(size(ix));

% s = sum(max(freq(ix), thres));

% parmhat = lognfit(ix, alpha, censoring, freq(ix));
% logdat = log(lognpdf(ix0, parmhat(1), parmhat(2)));

parmhat = gamfit(ix, alpha, censoring(ix), freq1(ix)); % max(freq(ix), thres) ./ s);
[m, s] = gam2ms(parmhat(1), parmhat(2));

logdat = bml.distrib.loggampdf_ms(ix0, m, s) + log(sum0);

if any(isnan(logdat))
    disp(m);
    disp(s);
    disp(log(nansum(freq)));
    plot(logdat);
    keyboard; % DEBUG
end

return;

%% Test
n = 1e3;
m0 = 1 + rand;
s0 = m0 * rand;

ix = 0:0.1:(m0 * 5);

r = gamrnd_ms(m0, s0, [1, n]);
freq = hist(r(r <= ix(end)), ix);

[logdat, m, s] = bml.distrib.loggamfit_reg(freq);

subplot(2,1,1);
plot(ix, freq, 'b-', ix, exp(logdat), 'r--');
xlim(ix([1, end]));

subplot(2,1,2);
plot(ix, log(max(freq, eps)), 'b-', ix, logdat, 'r--');

% ylim([-5, max(max(logdat) * 1.1, 0)]);
xlim(ix([1, end]));