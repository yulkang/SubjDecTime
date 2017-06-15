function C = style_pred(style_args)
if ~exist('style_args', 'var'), style_args = {}; end
C = varargin2C(style_args, {
    'Color', 'k'
    'Marker', 'none'
    'LineStyle', '-'
    'LineWidth', 1
    });
end