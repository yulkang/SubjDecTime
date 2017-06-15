function [m, st] = gamparam2ms(k, th)
% Gamma distribution's mean and stdev given shape and scale parameters.
%
% [m, st] = gamparam2ms(k, th)

m  = k .* th;
st = sqrt(k .* th .^ 2);
