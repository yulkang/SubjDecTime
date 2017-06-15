function lim = limRange(lim, varargin)
% lim = limRange(lim, varargin)
%
% 'margin', 0.1
% 'symmetric', false

S = varargin2S(varargin, {
    'margin', 0.1
    'symmetric', false
    });

lim = [min(lim), max(lim)];
if S.symmetric
    r = max(abs(lim));
    r2 = r * (1 + S.margin);
    lim = [-r2, r2];
else
    r = lim(2) - lim(1);
    r2 = r * (1 + S.margin);
    lim = [lim(2) - r2, lim(1) + r2];
end