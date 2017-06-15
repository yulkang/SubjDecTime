function [h, he] = errorbar_wo_tick(x, y, l, u, plot_args, tick_args, varargin)
% [h, he] = errorbar_wo_tick(x, y, le, ue, plot_args, tick_args, ...)
% [h, he] = errorbar_wo_tick(x, y, e, [], plot_args, tick_args, ...)

% 2015-2016 Yul Kang. hk2699 at columbia dot edu.

if nargin < 4 || isempty(u), u = l; l = -u; end
if nargin < 5, plot_args = {}; end
if nargin < 6, tick_args = {}; end

plot_args = varargin2S(varargin2plot(plot_args, {
    'Marker', 'o'
    'MarkerSize', 8
    'LineStyle', 'none'
    'LineWidth', 2
    'Color', 'k'
    'MarkerEdgeColor', 'w'
    }));

S = varargin2S(varargin, {
    'ax', gca
    });

if ~isfield(plot_args, 'MarkerFaceColor')
    plot_args.MarkerFaceColor = plot_args.Color;
end
plot_args = varargin2C(plot_args);

tick_args = varargin2plot(tick_args, ...
    varargin2C(rmfield(varargin2S(plot_args), {
        'Marker', 'LineWidth', 'LineStyle'
        }), {
        'Marker', 'none'
        'LineStyle', '-'
        'LineWidth', 0.5
        'Color', 'k'
        }));
    
h = plot(S.ax, x, y, plot_args{:});
hold on;

he = plot(S.ax, [x(:), x(:)]', [y(:) - abs(l(:)), y(:) + u(:)]', tick_args{:});