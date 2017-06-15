function M = rotate_mat_3d(ax, deg)
% M = rotate_mat_3d(ax, deg)
%
% ax:
%   'yaw'   (x to y,   azimuth)
%   'pitch' (x-y to z, elevation)
%   'roll'  (y to z,   around x)
%   [ax1, ax2] or [x_in_ax, y_in_ax, z_in_ax]
%
% M = rotate_mat_3d([yaw, pitch, roll])
%   (in degree)
%
% 2014 (c) Yul Kang.


if ischar(ax)
    M = eye(3);
    
    switch ax
        case 'yaw'
            M(1:2,1:2) = rotate_mat(deg);
            
        case 'pitch'
            M([1 3], [1 3]) = rotate_mat(deg);
            
        case 'roll'
            M([2 3], [2 3]) = rotate_mat(deg);
            
        otherwise
            error('Unknown axis!');
    end
    
elseif nargin == 1
    M = rotate_mat_3d('yaw',   ax(1)) ...
      * rotate_mat_3d('pitch', ax(2)) ...
      * rotate_mat_3d('roll',  ax(3));
  
elseif nargin >= 2
    M = eye(3);
    M(ax, ax) = rotate_mat(deg);
    
else
    error('Bad input format!');
end
