function varargout = diffDistrib(varargin)
% c = diffDistrib(a, b, varargin)
%
% 'op', 'exact' % 'exact' or 'random'
% 'n',  1000    % ignored if op == 'exact'
[varargout{1:nargout}] = diffDistrib(varargin{:});