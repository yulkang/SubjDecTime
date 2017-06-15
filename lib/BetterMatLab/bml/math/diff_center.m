function v = diff_center(v)
% v = diff_center(v)

n = size(v,2);

v = diff(v);
v = ([zeros(1,n); v] + [v; zeros(1,n)]) / 2;