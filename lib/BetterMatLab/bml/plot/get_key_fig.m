function get_key_fig(h, evt)
% Set UserData.key as the evt when set(gcf, 'KeyPressFcn', @get_key_fig)
%
% get_key_fig(h, evt)
set_UserData(h, 'key', evt);