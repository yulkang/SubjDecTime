function varargout = angDist(varargin)
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
[varargout{1:nargout}] = angDist(varargin{:});