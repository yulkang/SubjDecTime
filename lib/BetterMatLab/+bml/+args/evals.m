function varargout = evals(varargin)
% EVALS  Evaluate each cell. If a function handle, return the value.
%
% C = evals(C)
[varargout{1:nargout}] = evals(varargin{:});