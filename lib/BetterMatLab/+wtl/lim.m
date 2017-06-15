function l = lim(h_ax, ax, v)
% l = lim(h_ax, ax='x'|'y', v)

h_v = h_ax.getView;
    
if nargin >= 3
    if ax=='x'
        h_v.setXLeft(v(1));
        h_v.setXRight(v(2));
    elseif ax =='y'
        h_v.setYBottom(v(1));
        h_v.setYTop(v(2));
    end
end

if nargout > 0
    if ax=='x'
        l = [h_v.getXLeft, h_v.getXRight];
    elseif ax=='y'
        l = [h_v.getYBottom, h_v.getYTop];
    end
end