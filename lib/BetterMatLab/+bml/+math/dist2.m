function varargout = dist2(varargin)
% DIST2     Squared distance between two multidimensional coordinates.
%
% res = dist2(x1, x2, dim)
%
% dim   : Along which dimension of the array the spatial dimension increases.
%         Defaults to 1.
[varargout{1:nargout}] = dist2(varargin{:});