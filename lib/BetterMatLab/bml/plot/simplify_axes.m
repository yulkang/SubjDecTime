function simplify_axes(ax)
% simplify_axes(ax)
if ~exist('ax', 'var')
    ax = gca;
end

set(ax, 'Box', 'off', 'TickDir', 'out', 'XGrid', 'on', 'YGrid', 'on');