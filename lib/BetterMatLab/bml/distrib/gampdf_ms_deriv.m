function [dp_dm, dp_ds] = gampdf_ms_deriv(x, m, s)
% [dp_dm, dp_ms] = gampdf_ms_deriv(x, m, s)
% 
% m: mean
% s: stdev
%
% See also: gampdf_deriv, gampdf_ms

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

k = m.^2./(s.^2);
th = (s.^2)./m;

[dp_dk, dp_dth] = gampdf_deriv(x, k, th);

dk_dm = 2 .* m ./ s.^2;
dk_ds = -2 .* m.^2 ./ s.^3;
dth_dm = -s.^2 ./ m.^2;
dth_ds = 2 .* s ./ m;

dp_dm = dk_dm .* dp_dk + dth_dm .* dp_dth;
dp_ds = dk_ds .* dp_dk + dth_ds .* dp_dth;
end