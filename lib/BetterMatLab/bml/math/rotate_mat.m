function M = rotate_mat(deg)
% M = rotate_mat(deg)
%
% A)
% [new_x(:), new_y(:)] = [x(:), y(:)] * M'
%
% B) 
% new_xy = M * [x(:) y(:)]';
% new_xy = [new_x(:) new_y(:)]'

rad = deg / 180 * pi;

M = [cos(rad), -sin(rad)
     sin(rad),  cos(rad)];