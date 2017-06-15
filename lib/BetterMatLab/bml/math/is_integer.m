function tf = is_integer(v)
% Checks if v == round(v) (Can be true for double/single variables).
%
% 2015 Yul Kang.
tf = v == round(v);