function varargout = c2timeline(varargin)
% C2TIMELINE - Time of change to another string, suited to plot with TIMELINE
%
% [t, label] = c2timeline(c)
%
% [t, label] = c2timeline({'a', 'a', 'b', 'b', 'a', 'b'})
% t =
%      1     3     5     6
% label = 
%     'a'    'b'    'a'    'b' 
%
% See also: timeline
[varargout{1:nargout}] = c2timeline(varargin{:});