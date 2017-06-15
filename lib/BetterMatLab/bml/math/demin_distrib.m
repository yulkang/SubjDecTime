function fb = demin_distrib(fmin, fa)
% fb = demin_distrib(fmin, fa)
%
% Works on continuous positive distribution.
% Fit discrete distributions with a smooth continuous positive 
% distribution (e.t., normal or gamma) before applying.
% All elements must be positive. Omit zero when using gamma. 

Fmin = cumsum(fmin);
Fa   = cumsum(fa);

Fb   = (Fmin - Fa) ./ (1 - Fa);
Fb(end) = 1;
fb   = [Fb(1); diff(Fb(:))];