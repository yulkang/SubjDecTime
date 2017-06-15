function [img, w, a] = gabor(varargin)
% [img, weights, alpha] = gabor(...)
%
% INPUTS (all optional):
% 'size',     [100 100];
% 'rot_deg',  0
% 'ph_deg',   0
% 'lam_pix',  10 % Wavelength
% 'contrast', 0
% 'color1'    [255 255 255 255]
% 'color2'    [0   0   0   255]
%
% EXAMPLE:
% [img, w, a] = gabor('rot_deg', -10); 
% imagesc(img(:,:,1).*(a/255) + 128*(255-a)/255); 
% colorbar

S = varargin2S(varargin, {
    'size',     [100 100];
    'rot_deg',  0
    'ph_deg',   0
    'lam_pix',  5 % Wavelength
    'sig_pix',  10 % Envelope width
    'contrast', 1
    'color1'    [255 255 255]
    'color2'    [0   0   0  ]
    });

S.size = round(S.size);

% Grid
x = linspace(-S.size(1)/2, S.size(1)/2, S.size(1));
y = linspace(-S.size(1)/2, S.size(1)/2, S.size(1));
[X, Y] = meshgrid(x, y);

% Rotate with rot_deg
XY = rotate_mat(S.rot_deg) * [X(:), Y(:)]';
X  = reshape(XY(1,:), size(X));
Y  = reshape(XY(2,:), size(Y));

% Weight of color2 / (color1 + color2)
w  = (sin(X / S.lam_pix - S.ph_deg / 360) / 2 + 0.5) * S.contrast;

% Alpha by Gaussian envelope
a  = normpdf(sqrt(X.^2 + Y.^2), 0, S.sig_pix) ...
   * (255 / normpdf(0, 0, S.sig_pix));

% Image
img = zeros(S.size(1), S.size(2),4);

% Mix colors
for ii = 1:3
    img(:,:,ii) = w * S.color2(ii) + (1-w) * S.color1(ii);
end

% Alpha is given by the envelope
img(:,:,4) = a;