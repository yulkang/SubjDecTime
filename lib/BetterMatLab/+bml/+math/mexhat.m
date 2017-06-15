function y = mexhat(x)
% Negative of the 2nd derivative of a standard normpdf w/o the constant.
%
% mexhat(0) == 1
% mexhat(1) == mexhat(-1) == 0
y = -(x .^2 - 1) .* exp(-x.^2 ./ 2);