function simplify_axes_ch(ax)
if ~exist('ax', 'var')
    ax = gca;
end

simplify_axes(ax);
set(ax, 'YTick', 0:0.25:1);
axis_margin(ax, 'axis', 'x', 'type', 'symmetric');