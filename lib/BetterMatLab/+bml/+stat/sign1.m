function v = sign1(v)
% Same as sign except that sign1 gives 1 when sign is 0.
v = sign(v);
v(v == 0) = 1;