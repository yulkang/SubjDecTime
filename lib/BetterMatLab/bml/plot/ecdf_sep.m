function ecdf_sep(x, sep, varargin)
% ecdf_sep(x, sep, ...)
%
% OPTIONS:
% 'f_col', @cool
% 'freq', []
% 'ecdf_args', {}
% 'stairs_args', {}
% 'filt', []

S = varargin2S(varargin, {
    'f_col', @cool
    'freq', true(size(sep))
    'ecdf_args', {}
    'stairs_args', {}
    });

sep_incl = unique(sep);
n_sep    = length(sep_incl);

col      = S.f_col(n_sep);

% Draw ecdf plots for each sep
for i_sep = 1:n_sep
    c_sep = sep_incl(i_sep);
    
    incl = sep == c_sep;
    
    [f, xx] = ecdf(x(incl), 'frequency', S.freq(incl), S.ecdf_args{:});
    stairs(xx, f, 'Color', col(i_sep,:));
    
    hold on;
end