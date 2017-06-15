function [x, y, M] = rotate_2d(rad, x, y)
% [x, y, M] = rotate_2d(rad, x, y)

siz = size(x);
if ~isequal(size(y), siz), error('x and y should have identical sizes!'); end

M  = [cos(rad), -sin(rad); sin(rad), cos(rad)];
xy = M * [x(:)'; y(:)'];

x = reshape(xy(1,:), siz);
y = reshape(xy(2,:), siz);