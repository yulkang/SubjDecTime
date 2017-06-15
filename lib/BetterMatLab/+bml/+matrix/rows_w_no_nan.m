function varargout = rows_w_no_nan(varargin)
% varargout = rows_w_no_nan(varargin)

varargin_double = cellfun(@double, varargin, ...
    'UniformOutput', false);

siz0s = cellfun(@(v) num2cell(size(v)), varargin, ...
    'UniformOutput', false);

n_row = size(varargin{1}, 1);
no_nan = true(n_row, 1);
for ii = 1:numel(varargin)
    no_nan = no_nan & all(~isnan(reshape(varargin_double{ii}, n_row, [])), 2);
end

varargout = cellfun(@(v) v(no_nan, :), varargin, ...
    'UniformOutput', false);

varargout = cellfun(@(v, siz0) reshape(v, [], siz0{2:end}), ...
    varargout, siz0s, ...
    'UniformOutput', false);
end