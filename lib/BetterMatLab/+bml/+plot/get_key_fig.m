function varargout = get_key_fig(varargin)
% Set UserData.key as the evt when set(gcf, 'KeyPressFcn', @get_key_fig)
%
% get_key_fig(h, evt)
[varargout{1:nargout}] = get_key_fig(varargin{:});