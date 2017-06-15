function varargout = elcov(varargin)
% Find an ellipse representing covariance.
%
% x, y : vector
% sc   : 'std', 'sem', a scalar, or a function handle of a form @(x, y) for scaling sqrt(cov).
% el   : 100 x (x,y) matrix representing the ellipse.
% ev   : scaled eigenvectors.
% mx,my: mean x and y.
%
% See http://stackoverflow.com/questions/3417028/ellipse-around-the-data-in-matlab
[varargout{1:nargout}] = elcov(varargin{:});