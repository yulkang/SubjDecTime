function [f, n, x] = filt_gauss_robust(sig, w) 
% Gaussian filter that is robust (uses diff(cdf)), and of odd length.
%
% [f, n, x] = filt_gauss_robust(sig, w=6)
%
% sig: in the unit of number of elements.
% w: width of the filter in the unit of sigma.
%
% f: filter.
% n: total number of elements.
% x: index. 0 at the center, positive to the right, negative to the left.
%
% Example
% -------
% dt = 0.01;
% t = 0:dt:1;
% nt = length(t);
% sig = 0.1;
% f = bml.filt.filt_gauss_robust(round(sig/dt));
% s = double(t == 0);
% ss = conv(s,f,'same');
% plot(t,s,t,ss);
% disp(sum(f) - 1);
%
% 2015-2016 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

if nargin < 2, w = 6; end

if sig * w <= 1
    f = 1;
    n = 1;
    x = 0;
    return;
end

x = linspace_sym(sig*w, 1);
dx = x(2) - x(1);

x_bnd = [x(1) - dx / 2, x(:)' + dx / 2];

f = diff(normcdf(x_bnd, 0, sig));
f = f ./ sum(f);

n = length(f);
end