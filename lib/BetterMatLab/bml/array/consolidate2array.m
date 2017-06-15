function [a, sub] = consolidate2array(x, y, varargin)
% [a, sub] = consolidate2array(x, y, varargin)

error('Under construction!');

S = varargin2S(varargin, {
    'f',    @mean
    'xcon', []
    'tol',  0
    'siz',  []
    'def',  @zeros
    });

[xcon, ycon] = consolidate(x, y, S.f, S.tol, S.xcon);

[a, sub] = ix2array(ycon, xcon, S);
