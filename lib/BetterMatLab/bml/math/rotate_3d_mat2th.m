function deg = rotate_3d_mat2th(R)
% deg = rotate_3d_mat2th(R)

deg    = zeros(1,3);          
deg(1) = atan2(R(2,1), R(1,1)) / pi * 180;
R      = rotate_mat_3d('yaw',   -deg(1)) * R;
deg(2) = atan2(R(3,1), R(1,1)) / pi * 180;
R      = rotate_mat_3d('pitch', -deg(2)) * R;
deg(3) = atan2(R(3,2), R(2,2)) / pi * 180;
