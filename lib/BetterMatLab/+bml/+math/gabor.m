function varargout = gabor(varargin)
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
[varargout{1:nargout}] = gabor(varargin{:});