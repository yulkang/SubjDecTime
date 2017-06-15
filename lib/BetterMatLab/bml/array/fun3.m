function [Z, X, Y] = fun3(f, v, x, y, varargin)
% function results for each x and y
%
% [Z, X, Y] = fun3(f, v, x, y, varargin)
%
% See also: ACCUMARRAY

S = varargin2S(varargin, {
    });

x_incl = unique(x);
y_incl = unique(y);

n_x = length(x_incl);
n_y = length(y_incl);

Z = zeros(n_y, n_x);

for i_x = 1:n_x
    c_x = x_incl(i_x);
    
    for i_y = 1:n_y
        c_y = y_incl(i_y);
        
        filt = (x == c_x) & (y == c_y);
        
        Z(i_y, i_x) = f(v(filt));
    end
end

[X, Y] = meshgrid(x_incl, y_incl);