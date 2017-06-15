function [h, res] = glmplot(X, y, distr, glm_args, plot_args)
% [h, res] = glmplot(X, y, distr, glm_args, plot_args)

if nargin < 4
    glm_args = {};
end
if nargin < 5
    plot_args = {};
end
S_plot = varargin2S(plot_args, {
    'Color', 'k'
    'Solid', true
    'LineStyle', '-'
    });

res = glmwrap(X, y, distr, glm_args{:});

switch distr
    case 'binomial'
        assert(size(X, 2) == 1, 'Only one IV is supported now!');
        [xs_data,~,ix] = unique(X(:,1));
        
        assert(islogical(y));
        p = accumarray(ix, y, [],@mean);
        
        xs_pred = linspace(xs_data(1), xs_data(end));
        p_pred = glmval(res.b, xs_pred, 'logit', res.stats);
        
        h.pred = plot(xs_pred, p_pred, S_plot.LineStyle, ...
            'Color', S_plot.Color);
        hold on;
        
        if S_plot.Solid
            C = {
                'MarkerFaceColor', S_plot.Color, ...
                'MarkerEdgeColor', 'w'
                };
        else
            C = {
                'MarkerFaceColor', 'w', ...
                'MarkerEdgeColor', S_plot.Color
                };
        end
        
        h.data = plot(xs_data, p, 'o', C{:});
        hold off;
        
    otherwise
        error('distr=%s is not supported yet!', distr);
end
end