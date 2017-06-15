function h = plot_significant_interval(sig, x, varargin)
% h = plot_significant_interval(sig, x)
%
% sig : logical vector.
% x : vector of the same length as sig. Assumed to be regularly spaced.
%
% See also: bml.plot.line_on_axis, bml.math.consecutive
%
% 2016 Yul Kang. hk2699 at columbia dot edu.



assert(isvector(sig));
if exist('x', 'var')
    assert(isvector(x));
    assert(numel(sig) == numel(x));
else
    x = 1:length(sig);
end
if numel(x) < 2
    dx = 1;
else
    dx = x(2) - x(1);
end

[~, ~, st, en] = bml.math.consecutive(sig);
n_consec = length(st);

hold on;
for ii = n_consec:-1:1
    sig_int = [x(st(ii)) - 0.5 * dx, x(en(ii)) + 0.5 * dx];
    h(ii) = bml.plot.line_on_axis(sig_int(1), sig_int(2), varargin{:});
    hold on;
end
hold off;
end