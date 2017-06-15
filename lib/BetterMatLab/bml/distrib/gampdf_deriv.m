function [dp_dk, dp_dth] = gampdf_deriv(x, k, th)
% [dp_dk, dp_dth] = gampdf_deriv(x, k, th)
%
% k: shape
% th: scale
%
% See also: gampdf_ms_deriv, gampdf

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

p = gampdf(x, k, th);

dp_dk = p .* (-psi(k) ./ gamma(k)) ...
      + log(x) ...
      - k - 1;

dp_dth = p .* (-k ./ th + x ./ th.^2);