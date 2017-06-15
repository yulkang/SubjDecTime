function varargout = copyprops_old(varargin)
% dst = copyprops_old(dst, src, ...)
%
% Deprecated. Use bml.oop.copyprops instead.
%
% src, dst : struct or an object
%
% OPTIONS
% -------
% 'props', []
% 'skip_absent', true
% 'skip_dependent', true
% 'skip_transient', true
% 'skip_hidden', false
%
% 2015 (c) Yul Kang. yul dot kang dot on at gmail.
[varargout{1:nargout}] = copyprops_old(varargin{:});