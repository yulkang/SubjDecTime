function varargout = dataTip(varargin)
% dataTip(x, y, varargin)
%
% Options:
% 'v', [] % vector or cell array. Defaults to y.
% 'dx', 0
% 'dy', 0.05
% 'dxUnit', 'normalized'
% 'dyUnit', 'normalized'
% 'fmt', '%1.2f'
% 'textOpt', {}
%
% Text options:
% 'HorizontalAlignment', 'center'
% 'VerticalAlignment',   'top'
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.
[varargout{1:nargout}] = dataTip(varargin{:});