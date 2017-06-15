function h = plot_logistic_data(x, ch, varargin)
% h = plot_logistic_data(x, ch, varargin)

assert(isvector(x));
assert(isvector(ch));

incl = ~isnan(x) & ~isnan(ch);
x = x(incl);
ch = ch(incl);

S = varargin2S(varargin, {
    'n_bin', min(9, numel(unique(x)))
    'plot_args', {}
    });
S.plot_args = varargin2plot(S.plot_args, {
    'o-'
    });

[bin, ~, x_plot] = quantilize(x, S.n_bin);

n_all = accumarray(bin, 1, [S.n_bin, 1], @sum);
n_ch = accumarray(bin, ch, [S.n_bin, 1], @sum);

incl_plot = n_all > 0;

p_ch = n_ch ./ n_all;

h = plot(x_plot(incl_plot), p_ch(incl_plot), S.plot_args{:});
end