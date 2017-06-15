function varargout = colorPoints(varargin)
% hNew = colorPoints(x, y, varargin)
% hNew = colorPoints(hOld, [], varargin)
%
% OPTIONS
% -------
% 'colors',    @hsv2
% 'deleteOld', false
% 'plotOpt',   {}
% 'reverseColor', false
[varargout{1:nargout}] = colorPoints(varargin{:});