function v = tick(h_ax, ax, v)
% v = tick(h_ax, ax='x'|'y', v)

h_v = h_ax.getView;
    
if nargin >= 3
    if ax == 'x'
        h_v.setMajorXHint(v)
    elseif ax == 'y'
        h_v.setMajorYHint(v)
    end
end

if nargout > 0
    if ax == 'x'
        v = h_v.getMajorXHint;
    elseif ax == 'y'
        v = h_v.getMajorYHint;
    end
end