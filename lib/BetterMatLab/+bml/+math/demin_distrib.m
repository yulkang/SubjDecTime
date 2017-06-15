function varargout = demin_distrib(varargin)
% fb = demin_distrib(fmin, fa)
%
% Works on continuous positive distribution.
% Fit discrete distributions with a smooth continuous positive 
% distribution (e.t., normal or gamma) before applying.
% All elements must be positive. Omit zero when using gamma. 
[varargout{1:nargout}] = demin_distrib(varargin{:});