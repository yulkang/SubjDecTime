function varargout = assert_isequal_within(varargin)
% [tf, a, b, sub, v] = assert_isequal_within(a, b, tol=1e-6, ...)
%
% a dictates the size used in the report when there is discrepancy.
%
% OPTION
% ------
% 'relative_tol', true
[varargout{1:nargout}] = assert_isequal_within(varargin{:});