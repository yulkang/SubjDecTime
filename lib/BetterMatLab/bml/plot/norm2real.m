function d = norm2real(ax, v, unit)
% Convert units of the axes into other units
%
% v   : in axis's unit
% unit: 'pixels', 'inches', 'centimeters', 'points'
% ax  : Only width is considered. Use axis equal before using norm2real.

set(ax, 'Units', unit);
pos     = get(ax, 'Position');
XLim    = get(ax, 'XLim');
XDist   = XLim(2) - XLim(1);
d       = v / XDist * pos(3);