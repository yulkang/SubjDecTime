function [my, ey, mx, ex] = running_mean_const_bin(y, varargin)
% [my, ey, mx, ex] = running_mean_const_bin(y, varargin)

C = varargin2C(varargin, {
    'fun', @(y,x) {nanmean(x(:)), nansem(x(:)), nanmean(y(:)), nansem(y(:))}
    });

res = running_fun_const_bin(y, C{:});
res = cat(1,res{:});
my  = [res{:,1}];
ey  = [res{:,2}];
mx  = [res{:,3}];
ex  = [res{:,4}];
