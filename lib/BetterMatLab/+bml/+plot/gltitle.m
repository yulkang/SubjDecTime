function varargout = gltitle(varargin)
% Column and row titles
%
% hgl = gltitle(h, op, t, varargin)
%
% h     : Array of axes
% op    : 'all', 'row', 'col'
% t     : Title. In case of 'all', a string. In case of 'row' or 'col', a cell array of strings.
% shift : [xshift, yshift] or [xshift, yshift, zshift]. Defaults to [0.05, -0.05].
[varargout{1:nargout}] = gltitle(varargin{:});