function h = fig2subplotRC(old_fig, new_fig, varargin)
% h = fig2subplotRC(old_fig, new_fig, nR, nC, r, c)

% subplotRC should not come after copyobj, since the new obj will be 
% deleted by subplot.
figure(new_fig);
h       = subplotRC(varargin{:});

% Copy obj
ax      = get(old_fig, 'Children');
new_ax  = copyobj(ax, new_fig);

% Set the position
set(new_ax, 'Position', get(h, 'Position'));
delete(h);
