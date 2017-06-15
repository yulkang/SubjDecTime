function xy = grating_xy(freq, ph, th, siz)
% grating_xy(freq, ph, th, siz)
%
% freq: how many to put between -1 and 1
% ph  : phase. from 0 to 1.
% th  : rotation. in deg.
% siz : scalar scale.
%
% xy  : (2, freq*2) coordinates to feed Screen('DrawLines').

x = linspace(-1, 1, freq + 1);
x = repmat(x(1:(end-1)) + ph * 2 / freq, [2 1]);
y = repmat([-1; 1], [1 freq]);

rad = th / 180 * pi;

xy = (siz * [x(:), y(:)] * [cos(rad), -sin(rad); sin(rad), cos(rad)])';