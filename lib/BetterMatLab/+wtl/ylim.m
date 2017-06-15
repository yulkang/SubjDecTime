function yl = ylim(h_ax, v)
% yl = ylim(h_ax, v)

h_v = h_ax.getView;
    
if nargin >= 2
    h_v.setYTop(v(1));
    h_v.setYBottom(v(2));
end

if nargout > 0
    yl = [h_v.getXLeft, h_v.getXRight];
end