function xy = get_cur_coord(h, ~)
% Save current coordinate (last clicked) of an axes to its UserData.xy_cur
%
% xy = get_cur_coord(h, ~)

xy = get(h, 'CurrentPoint');
xy = xy(1, 1:2);

set_UserData(h, 'xy_cur', xy);
end