function fprintf_columns(fmt, c, n_col)
% FPRINTF_COLUMNS  print cell vector of strings in columns.
%
% fprint_columns(fmt, c, n_col)

c = c(:)';
n = length(c);

c = reshape([c, cell(1, n_col - rem(n, n_col))], [], n_col)';
fprintf([repmat(fmt, [1, n_col]), '\n'], c{:});
fprintf('\n');