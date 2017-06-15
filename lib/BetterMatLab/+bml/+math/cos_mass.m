function v = cos_mass(t)
% raised discrete cos as a difference of sin such that it sums to 1 over -pi:pi.
% Sums to 1 as long as t(1) <= -pi + dt/2 and t(end) >= pi - dt/2.
%
% EXAMPLE:
% >> plot(bml.math.cos_mass(linspace(-pi, pi, 20)))
%
% >> sum(bml.math.cos_mass(linspace(-pi, pi, 2)))
% ans = 1
%
% >> sum(bml.math.cos_mass(linspace(-pi, pi, 20)))
% ans = 1
%
% >> sum(bml.math.cos_mass(linspace(-pi, pi, 11) + pi * 0.1))
% ans = 1
%
% >> sum(bml.math.cos_mass(linspace(-pi, pi, 11) + pi * 0.2))
% ans = 0.9992
%
% >> sum(bml.math.cos_mass(linspace(-pi, pi, 2000)))
% ans = 1.0000
%
% 2016 Yul Kang. hk2699 at columbia dot edu.

dt = mean(diff(t));
t_bnd0 = [t(1) - dt / 2; (t(:) + (t(:) + dt)) ./ 2];
t_bnd = max(min(t_bnd0, pi), -pi);
v0 = sin(t_bnd) + t_bnd;
v = diff(v0) ./ (pi * 2);

if isrow(t), v = v'; end
