function xl = xlim(h_ax, v)
% xl = xlim(h_ax, v)

h_v = h_ax.getView;
    
if nargin >= 2
    h_v.setXLeft(v(1));
    h_v.setXRight(v(2));
end

if nargout > 0
    xl = [h_v.getXLeft, h_v.getXRight];
end