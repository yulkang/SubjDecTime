function y = valSpline(x,a,b,c,d)
% function y = valSpline(x,a,b,c,d)
%
% The knots are at 1:(N+1). Also, 1<=x<=(N+1).
%
% ref: http://mathworld.wolfram.com/CubicSpline.html, eq. (1)
%
% See also: estSpline

k = max(min(floor(x), size(a,1)), 1); % discretize.
t = x - k;

y = a(k) + b(k).*t + c(k).*t.^2 + d(k).*t.^3;
