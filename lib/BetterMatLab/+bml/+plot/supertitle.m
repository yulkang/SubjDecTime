function h = supertitle(ax, str, varargin)
% h = supertitle(ax, str, varargin)
%
% 'location', 'north' % 'north'|'south'|'west'|'east'
% 'margin', 0.01
% 'height', 0.1
% 'margin_unit', 'relative'
% 'height_unit', 'relative'
% 'options', {}

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'location', 'north' % 'north'|'south'|'west'|'east'
    'margin', 0.01
    'height', 0.1
    'margin_unit', 'relative'
    'height_unit', 'relative'
    'options', {}
    });

if isempty(ax) || (isscalar(ax) && strcmp(get(ax, 'Type'), 'Figure'))
    ax = bml.plot.subplot_by_pos(ax);
end

%%
pos_all = cell2mat(get(ax, 'Position'));
pos_all(:,[3,4]) = pos_all(:,[1,2]) + pos_all(:,[3,4]);
min_x = min(pos_all(:,1));
min_y = min(pos_all(:,2));
max_x = max(pos_all(:,3));
max_y = max(pos_all(:,4));

width0 = max_x - min_x;
height0 = max_y - min_y;

switch lower(S.location)
    case 'north'
        y = max_y + height0 * S.margin;
        width = width0;
        height = height0 * S.height;
        
        options = varargin2C(S.options, {
            'EdgeColor', 'none'
            'HorizontalAlignment', 'center'
            'VerticalAlignment', 'bottom'
            });
        
        h = annotation('textbox', [min_x, y, width, height], ...
            'String', str, options{:});
        
    otherwise
        error('Under construction: location=%s\n', S.location);
%     case 'south'
%     case 'west'
%     case 'east'
end
