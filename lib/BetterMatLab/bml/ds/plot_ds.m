function h = plot_ds(ds, col_x, col_y, varargin)
% h = plot_ds(ds, col_x, col_y, varargin)
%
% Options
% -------
% 'plot_opt',     {}, ...

S = varargin2S(varargin, { ...
    'plot_opt',     {}, ...
    });

h = plot(ds.(col_x), ds.(col_y), S.plot_opt{:});
xlabel(strrep(col_x, '_', '-'));
ylabel(strrep(col_y, '_', '-'));