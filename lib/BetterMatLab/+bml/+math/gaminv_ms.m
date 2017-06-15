function varargout = gaminv_ms(varargin)
% [p, k, theta] = gaminv_ms(X, m, s)
%
% m: mean = k * theta
% s: standard deviation = sqrt(k * theta^2)
%
% With shape parameter k an integer, it gives an Earlang distribution,
% the distribution of the sum of k independent variables with
% mean of 1/theta, or rate of theta.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = gaminv_ms(varargin{:});