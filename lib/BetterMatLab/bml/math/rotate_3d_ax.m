function R = rotate_3d_ax(deg, u_ax)
% ROTATE_3D_AX  3-D rotation matrix around the given axis vector.

rad = deg / 180 * pi;

R = cos(rad) * eye(3) + sin(rad) * cross_prod_mat(u_ax);
end

function M = cross_prod_mat(u)
    M = [  0,    -u(3),   u(2)
         u(3),      0,   -u(1)
        -u(2),    u(1),     0];
end