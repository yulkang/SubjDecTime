function ds = unique_index_ds(factor, ds, ix, unique_cols, seed_cols, seed_fun)
% ds = unique_index_ds(factor, ds, ix, unique_cols, seed_cols, seed_fun)
%
% factor      : A struct each of whose fields contain repertoires for each unique_col.
% ds          : Dataset.
% ix          : Logical or numerical index of the rows to attach seeds.
% unique_cols : Cell array of column names. Seeds will be unique only for 
%               rows unique w.r.t. these columns.
% seed_cols   : Char or cell array of column(s) to save the seed (random numbers)
% seed_fun    : Function to apply to the numbers from rand(). Defaults to rand2seed.

uni_ix = zeros(length(ds), length(unique_cols));
uni_n  = zeros(1,          length(unique_cols));

for i_col = 1:length(unique_cols)
    c_col = unique_cols{i_col};
    uni_ix(:,i_col) = bsxFind(ds.(c_col)(ix), factor.(c_col));
    uni_n(i_col)    = length(factor.(c_col));
end



n_rand = max(ic);

% Get n_seed_cols
if ischar(seed_cols)
    seed_cols = {seed_cols};
elseif ~iscell(seed_cols)
    error('seed_cols must be either a string or cell array of strings!');
end

n_seed_cols = length(seed_cols);

% Get c_rand
if ~isempty(factor)
    c_rand = rand(factor, n_rand, n_seed_cols);
else
    c_rand = rand(n_rand, n_seed_cols);
end

if exist('seed_fun', 'var') && ~isempty(seed_fun)
    c_rand = seed_fun(c_rand);
else
    c_rand = rand2seed(c_rand);
end

% attach seed_cols
for i_col = 1:n_seed_cols
    ds.(seed_cols{i_col})(ix,1) = c_rand(ic, i_col);
end