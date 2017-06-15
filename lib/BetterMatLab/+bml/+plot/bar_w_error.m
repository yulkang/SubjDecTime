function [h_bar, h_err] = bar_w_error(x, y, le, ue, bar_args, error_args)
% [h_bar, h_err] = bar_w_error(x, y, le, ue, bar_args, error_args)

if ~exist('bar_args', 'var')
    bar_args = {};
end
bar_args = varargin2C(bar_args, {
    'FaceColor', 'w'
    'EdgeColor', 'k'
    });

if ~exist('error_args', 'var')
    error_args = {};
end
error_args = varargin2plot(error_args, {
    'LineStyle', '-'
    'Color', 'k'
    'Marker', 'none'
    });

plot_args = varargin2plot({
    'LineStyle', 'none'
    'Marker', 'none'
    });

h_bar = bar(x, y, bar_args{:});
hold on;

[~, h_err] = errorbar_wo_tick(x, y, le, ue, plot_args, error_args);
hold off;
