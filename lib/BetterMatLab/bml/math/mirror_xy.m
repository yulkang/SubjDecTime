function xy = mirror_xy(xy, deg)
% Mirror around the vector pointing the direction deg
%
% xy = mirror_xy(xy, deg)
%
% xy: 2 x N
% deg: a scalar

rad = deg / 180 * pi;

% Vector orthogonal to mot_dir
ax_vec = [cos(rad), -sin(rad)]; 

% Only jumping dots are reflected.                
% Reflection about mot_vec_orth
xy = ...
    [ax_vec(1)^2 - ax_vec(2)^2, 2 * ax_vec(1) * ax_vec(2)
     2 * ax_vec(1) * ax_vec(2), ax_vec(2)^2 - ax_vec(1)^2
    ] * xy;
