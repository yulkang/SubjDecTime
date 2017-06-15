function varargout = discrete_step(varargin)
% discrete_step  Discretize to nearest value.
%
% v = discrete_step(v, step, op, offset)
%
% op = @round (default) | @ceil | @floor
% offset = 0
[varargout{1:nargout}] = discrete_step(varargin{:});