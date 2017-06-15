function imMat = grating_x(siz, freq, ph, sig)
% imMat = grating_x(siz, freq, ph, sig)

imMat = grating_mat(siz, freq, ph, sig);
imMat = (imMat + imMat') / 2;