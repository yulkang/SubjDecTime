function varargout = binsearch(varargin)
% BINSEARCH  Solution for bounded monotonic increasing function.
%
% [x, d] = binsearch(f, lb, ub, varargin)
%
% x: root
% d: discrepancy
%
% Options:
% 'tol_f' 1e-12
% 'tol_x' 1e-12
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = binsearch(varargin{:});