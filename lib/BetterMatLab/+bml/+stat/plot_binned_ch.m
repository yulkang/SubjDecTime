function [h, y_bin, x, x_bin] = plot_binned_ch(x0, ch, varargin)
% [h, y_bin, x, x_bin] = plot_binned_ch(x0, ch, varargin)
S = varargin2S(varargin, {
    'n_bin', 9
    'plot_args', {'o'};
    });

[x_bin, ~, x] = quantilize(x0, S.n_bin);
y_bin = accumarray(x_bin, ch, [], @nanmean);
h = plot(x, y_bin, S.plot_args{:});
end