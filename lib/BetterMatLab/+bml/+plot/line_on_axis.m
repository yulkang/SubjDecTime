function h = line_on_axis(st, en, varargin)
% h = line_on_axis(st, en, varargin)
%
% OPTIONS:
% 'axis', 'x'
% 'width', 0.025 % proportion to diff(ylim)
% 'color', [0 0 0]
% 'alpha', 0.2
% 'base', [] % empty for the edge of the plot; or a scalar (e.g., 0)
% 'margin', 0.01 % proportion to diff(ylim)
% 'EdgeColor', 'w'
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'axis', 'x'
    'width', 0.025 % proportion to diff(ylim)
    'color', [0 0 0]
    'alpha', 0.2
    'base', [] % empty for the edge of the plot; or a scalar (e.g., 0)
    'margin', 0.01 % proportion to diff(ylim)
    'EdgeColor', 'w'
    });

switch S.axis
    case 'x'
        x = [st, en, en, st];
        
        y_lim0 = ylim;
        w = diff(y_lim0) * S.width;
        margin = diff(y_lim0) * S.margin;
        
        if isempty(S.base)
            base = y_lim0(1);
        else
            base = S.base;
        end
        
        y = [0 0 w w] + base + margin;
        h = patch('XData', x, 'YData', y, ...
            'FaceColor', S.color, ...
            'FaceAlpha', S.alpha, ...
            'EdgeColor', 'none');
        
        ylim(y_lim0);
        
    otherwise
        error('axis = %s not implemented yet!\n', S.axis);
end
end