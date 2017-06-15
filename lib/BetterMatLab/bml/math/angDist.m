function [res, sgn] = angDist(ang1, ang2, unit)
% ANGDIST   Angular distance
%
% [res sgn] = angDist(ang1, ang2, unit);
%
% unit: 'rad' (default) or 'deg'.
%
% res : Distance. Always positive.
%
% sgn : 1 if ang2 - ang1 < half circle, -1 if ang2 - ang1 > half circle.
%       i.e., if angles increase anticlockwise, 
%             if going anticlockwise from ang1 to ang2 is closer, sgn = 1.
%             if going clockwise from ang1 to ang2 is closer, sgn = -1.

if (nargin < 3) || strcmp(unit, 'rad')
    divisor = 2*pi;
else
    divisor = 360;
end

res = mod(ang2 - ang1, divisor);
res = min(res, divisor - res);
sgn = res < (divisor - res);