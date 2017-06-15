function beautify_ch_axis(ax)
    if ~exist('ax', 'var'), ax = gca; end

    set(ax, ...
        'YTick', 0:0.5:1, ...
        'TickLength', [0.01, 0.05], ...
        'YGrid',' off');
    ylabel(ax, 'P_{right}');
    ylim(ax, [-0.05, 1]);
end