function varargout = get_cur_coord(varargin)
% Save current coordinate (last clicked) of an axes to its UserData.xy_cur
%
% xy = get_cur_coord(h, ~)
[varargout{1:nargout}] = get_cur_coord(varargin{:});