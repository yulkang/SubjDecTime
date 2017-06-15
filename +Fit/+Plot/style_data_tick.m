function C = style_data_tick(style_args)
if ~exist('style_args', 'var'), style_args = {}; end
C = varargin2C(style_args, {
    'Color', 'k'
    'Marker', 'none'
    'LineStyle', '-'
    'LineWidth', 0.5
    });
end