function [d,nam,ix,n] = choose_dir(d, varargin)
% [d,nam,ix,n] = choose_dir(d, varargin)

S = varargin2S(varargin, {
    'querry', 'Choose folder'
    });

[d, nam] = dirdirs(d);
[nam, ix] = input_defs(S.querry, nam);
d = d(ix);
n = length(d);
