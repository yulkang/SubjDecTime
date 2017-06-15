function [h_est, h_ci] = ci_on_axis(est, ci, varargin)
% [h_est, h_ci] = ci_on_axis(est, ci, varargin)
%
% est : a scalar.
% ci : a 2-vector [lb, ub].
%
% OPTIONS
% -------
% 'axis', 'x'
% 'color', [0 0 0]
% 'alpha_est', 1
% 'alpha_ci', 0.2
% 'len', 1/500
% 'base', [] % empty for the edge of the plot; or a scalar (e.g., 0)
%
% To show range without est, use line_on_axis, or give nan as est
%
% See also: line_on_axis
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'axis', 'x'
    'color', [0 0 0]
    'alpha_est', 1
    'alpha_ci', 0.2
    'len', 1/500
    'base', [] % empty for the edge of the plot; or a scalar (e.g., 0)
    });

C = varargin2C({
    'alpha', S.alpha_ci
    }, S);
h_ci = bml.plot.line_on_axis(ci(1), ci(2), C{:});
hold on;

C = varargin2C({
    'alpha', S.alpha_est
    }, S);
x_len = diff(xlim) * S.len;

h_est = bml.plot.line_on_axis(est - x_len, est + x_len, C{:});
hold off;
end