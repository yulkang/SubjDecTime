function varargout = glmpower_old(varargin)
% res = glmpower_old(b, x, link, varargin)
%
% b     : 1 x nb vector of parameter estimates
% x     : N x nb vector of the independent variables
% res   : n_sim x 1 struct array
% .b
% .dev
% .stats
% .y    : n_dat x 1 array of the simulated dependent variable.
% .b_sim : n_sim x nb array of the simulated independent variables.
[varargout{1:nargout}] = glmpower_old(varargin{:});