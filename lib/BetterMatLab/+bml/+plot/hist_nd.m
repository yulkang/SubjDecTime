function varargout = hist_nd(varargin)
% [n_hist, incl, ix] = hist_nd(x, varargin)
%
% X can have 2 to 4 columns: [x,y,C,R]. r and c will determine the
% row and column in hist3D. R and C will determine the position in 
% subplotRC.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = hist_nd(varargin{:});