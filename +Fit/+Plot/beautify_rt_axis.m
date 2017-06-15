function beautify_rt_axis(ax)
if ~exist('ax', 'var'), ax = gca; end

bml.plot.beautify_lim('ax', ax, 'xy', 'y');
bml.plot.beautify_tick(ax, 'y');

set(ax, ...
    'YGrid', 'off', ...
    'TickLength', [0.01, 0.05]);
end