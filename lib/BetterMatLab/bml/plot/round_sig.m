function v = round_sig(v, min_unit)
% v = round_sig(v, min_unit)

if nargin < 2, min_unit = 1; end

vmax = max(abs(v));
n_valid = floor(log10(vmax));
min_unit = 10^n_valid * min_unit;

v = ceil(abs(v)./min_unit).*sign(v).*min_unit;