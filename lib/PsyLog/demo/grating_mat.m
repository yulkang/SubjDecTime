function imMat = grating_mat(siz, lam, ph, sig)
% imMat = grating_mat(siz, lam, ph, sig)
%
% siz, lam, sig: all scalar, in the unit of pixel.
% lam: width of a cycle (pix).
% ph: scalar value (deg).
%
% imMat: A matrix whose values ranging from -1 to 1.

x      = (1:siz) - siz/2;
[X, Y] = meshgrid(x, x);
D2     = X.^2 + Y.^2;

imMat  = sin(((X / lam) - (ph / 360)) * 2* pi) ...
      .* exp(-D2 / (sig.^2));
