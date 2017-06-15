function v = stretch(v, fac, varargin)
% Stretch distribution without changing total probability.
% Works along the first dimension.
% fac < 1 shrinks the distribution.
%
% v = stretch(v, fac, ...)
%
% OPTIONS
% -------
% ... method for time interpolation.
% 'method', 'linear'
% ... preserve_total: when to preserve total along dimension 1.
% 'preserve_total', 'always' % 'always'|'shrink'|'stretch'|'never'
%
% EXAMPLE
% -------
% >> v = [1 10; 2 20; 3 30; 4 40; zeros(4, 2)]
% v =
%      1    10
%      2    20
%      3    30
%      4    40
%      0     0
%      0     0
%      0     0
%      0     0
% 
% >> bml.math.stretch(v, 0.5)
% ans =
%      3    30
%      7    70
%      0     0
%      0     0
%      0     0
%      0     0
%      0     0
%      0     0
% 
% >> bml.math.stretch(v, 0.25)
% ans =
%     10   100
%      0     0
%      0     0
%      0     0
%      0     0
%      0     0
%      0     0
%      0     0
% 
% >> bml.math.stretch(v, 0.1)
% ans =
%     10   100
%      0     0
%      0     0
%      0     0
%      0     0
%      0     0
%      0     0
%      0     0
% 
% >> bml.math.stretch(v, 2)
% ans =
% 
%     0.5000    5.0000
%     0.5000    5.0000
%     1.0000   10.0000
%     1.0000   10.0000
%     1.5000   15.0000
%     1.5000   15.0000
%     2.0000   20.0000
%     2.0000   20.0000
% 
% >> bml.math.stretch(v, 1.5)
% ans =
%     0.6667    6.6667
%     1.0000   10.0000
%     1.3333   13.3333
%     2.0000   20.0000
%     2.3333   23.3333
%     2.6667   26.6667
%          0         0
%          0         0
% 
% >> bml.math.stretch(v, 3)
% ans =
%     0.3333    3.3333
%     0.3333    3.3333
%     0.3333    3.3333
%     0.6667    6.6667
%     0.6667    6.6667
%     0.6667    6.6667
%     1.0000   10.0000
%     6.0000   60.0000
% 
% >> sum(bml.math.stretch(v, 3))
% ans =
%     10   100

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    ... method for time interpolation.
    'method', 'linear'
    ...
    ... preserve_total: when to preserve total along dimension 1.
    'preserve_total', 'always' % 'always'|'shrink'|'stretch'|'never'
    });

siz0 = size(v);
n = siz0(1);
n_rest = prod(siz0(2:end));
v = reshape(v, [n, n_rest]);
v = [zeros(1, n_rest); cumsum(v)];
v0_last = v(end, :);

ix0 = linspace(0, 1, n + 1);
ix1 = ix0 / fac;

v = max(interp1(ix0, v, ix1, S.method, 'extrap'), 0);

if fac < 1 && ismember(S.preserve_total, {'always', 'shrink'})
    ix_last = find(ix1 >= 1);
    
elseif fac > 1 && ismember(S.preserve_total, {'always', 'stretch'})
    ix_last = n + 1;
    
else
    ix_last = [];
end
n_last = length(ix_last);
v(ix_last, :) = repmat(v0_last, [n_last, 1]);

v = diff(v, [], 1);
v = reshape(v, siz0);