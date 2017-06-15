function C = style_data(style_args)
if ~exist('style_args', 'var'), style_args = {}; end
C = varargin2C(style_args, {
    'Marker', 'o'
    'MarkerSize', 4
    'MarkerFaceColor', 'k'
    'MarkerEdgeColor', 'w'
    'LineWidth', 0.5
    'LineStyle', 'none'
    });
end