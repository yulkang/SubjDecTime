function h = uicontrol_fill(ax, varargin)
% UICONTROL_FILL  Create a uicontrol to fill the axis, then delete the axis.
%
% h = uicontrol_fill(ax, varargin)
%
% Defaults
% --------
% 'Style',   'text'
% 'Position', pos
% 'Units',    'normalized'
% 'HorizontalAlignment', 'left'
% 'FontName', 'Monospaced'
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin == 0 || isempty(ax), ax = gca; end

pos = get(ax, 'Position');

% Completely fill
siz = pos(3:4);
siz2 = siz ./ [0.775, 0.815];
siz_off = siz2 * 0.0175;
siz_dif = siz2 - siz;
pos(1:2) = pos(1:2) - siz_dif/2 - siz_off;
pos(3:4) = siz2;

if ~isvalidhandle(varargin{1})
    C   = varargin2C(varargin, {
        'Style',   'text'
        'Units',    'normalized'
        'HorizontalAlignment', 'left'
        'FontName', 'Monospaced'
        'Position', pos
        });

    h   = uicontrol(C{:});
else
    h   = varargin{1};
    set(h, 'Units', 'normalized', 'Position', pos);
end
delete(ax);