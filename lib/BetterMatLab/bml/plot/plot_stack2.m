function [h, ix_nan] = plot_stack(h, x, y, ylabels, c, axes_opt, stack_opt)
% PLOT_STACK - Draw a stacked area plot
%
% h = plot_stack(x, y, ylabels, c, axes_opt, stack_opt)
%
% x : a row vector
% y : a matrix
% ylabels : a cell array of strings for each area
% c : a cell array of ColorSpecs.
%
% axes_opt
% stack_opt
%  y_lim: y_lim value

if nargin < 1 || isempty(h), h = gca; end

% Input preprocessing
n = size(y, 1);

if ~exist('c', 'var') || isempty(c)
    cmap2 = hsv(n+1);
    cmap1 = cmap2(2:(n+1),:); % cmap2((n+1):end,:);
    c = mat2cell(cmap1, ones(1,n), 3);
end
if ~exist('ylabels', 'var')
    ylabels = {};
end
if ~exist('axes_opt', 'var')
    axes_opt = {};
end
if ~exist('stack_opt', 'var')
    stack_opt = {};
end
axes_opt  = varargin2S(axes_opt);
stack_opt = varargin2S(stack_opt, {'ylabel_side', 'right_out'});

% Deal with missing values
ix_nan = isnan(x) | sum(isnan(y),1);
x = x(~ix_nan);
y = y(:, ~ix_nan);

for axes_opt_x = {'XTick', 'XTickLabel'}
    c_opt = axes_opt_x{1};
    
    if isfield(axes_opt, c_opt)
        axes_opt.(c_opt) = axes_opt.(c_opt)(~ix_nan);
    end
end

y_cum = cumsum(y, 1);

% Draw patch
for i_plot = n:-1:1
    patchAUC(x, y_cum(i_plot,:), c{i_plot}, 1);
end
% axis tight; % time-consuing
x_lim = [min(x(:)) max(x(:))];

if isfield(stack_opt, 'y_lim')
    y_lim = stack_opt.y_lim; 
else
    y_lim = [0 max(max(y_cum(:)), eps)];
end
xlim(x_lim);
ylim(y_lim);

% Label y axis
if ~isempty(ylabels)
    for i_plot = 1:n
        switch stack_opt.ylabel_side
            case 'SW'
                x_text = x_lim(1) * 0.95 + x_lim(2) * 0.05;
                y_text = y_lim(1) + diff(y_lim) *0.9 * (i_plot-0.5) / n;
                text(x_text, y_text, ylabels{i_plot}, 'HorizontalAlignment', 'left', ...
                    'BackgroundColor', c{i_plot});
                
            case 'right_out'
                x_text = x_lim(2) + diff(x_lim) * 0.05;
                y_text = y_lim(1) + diff(y_lim) *0.9 * (i_plot-0.5) / n;
                text(x_text, y_text, ylabels{i_plot}, 'HorizontalAlignment', 'left', ...
                    'BackgroundColor', c{i_plot});
                
            case 'center'
                x_text = x_lim(1) * 0.5 + x_lim(2) * 0.5;
                y_text = max(y_cum(:)) * (i_plot-0.5) / n;
                text(x_text, y_text, ylabels{i_plot}, 'HorizontalAlignment', 'center');
                
            case 'left'
                x_text = x_lim(1) * 0.95 + x_lim(2) * 0.05;
                if i_plot == 1
                    y_text = y_cum(i_plot,1) / 2;
                else
                    y_text = mean([y_cum(i_plot-1,1), y_cum(i_plot,1)]);
                end
                text(x_text, y_text, ylabels{i_plot}, 'HorizontalAlignment', 'left');
                
            case 'right'
                x_text = x_lim(1) * 0.05 + x_lim(2) * 0.95;
                if i_plot == 1
                    y_text = y_cum(i_plot,end) / 2;
                else
                    y_text = mean([y_cum(i_plot-1,end), y_cum(i_plot,end)]);
                end
                text(x_text, y_text, ylabels{i_plot}, 'HorizontalAlignment', 'right');
        end
    end
end

% Output
h = gca;

% Set options
if ~isempty(axes_opt)
    axes_opt = S2C(axes_opt);
    set(h, axes_opt{:});
end
