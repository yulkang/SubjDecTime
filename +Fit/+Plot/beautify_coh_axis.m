function beautify_coh_axis(ax)
    if ~exist('ax', 'var'), ax = gca; end

    set(ax, ...
        'XTick', [-.512, 0, .512], ...
        'XTickLabel', {'-51.2', '0', '51.2'}, ...
        'XGrid', 'off', ...
        'TickLength', [0.01, 0.05]);
%     set(ax, 'XTick', [-.512, -.256, 0, .256, .512]);
%     set(ax, 'XTickLabel', {'-51.2', '-25.6', '0', '25.6', '51.2'});
    xlabel(ax, 'Motion Strength (%)');
    xlim(ax, [-.512, .512] * 1.1);
end