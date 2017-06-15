function [x, d] = binsearch(f, lb, ub, varargin)
% BINSEARCH  Solution for bounded monotonic increasing function.
%
% [x, d] = binsearch(f, lb, ub, varargin)
%
% x: root
% d: discrepancy
%
% Options:
% 'tol_f' 1e-12
% 'tol_x' 1e-12
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
    
S = varargin2S(varargin, { ...
    'tol_f' 1e-12
    'tol_x' 1e-12
    });

x = (lb + ub) / 2;
d = f(x);

while (abs(d) > S.tol_f) && abs(ub - lb) > S.tol_x
    if d > 0
        ub = x;
    else
        lb = x;
    end
    
    x = (lb + ub) / 2;
    
    d = f(x);        
end