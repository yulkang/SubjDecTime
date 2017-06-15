function ds = unique_rand_ds(r, ds, ix, unique_cols, seed_cols, seed_fun)
% ds = unique_rand_ds(r, ds, ix, unique_cols, seed_cols, seed_fun)
%
% r           : RandStream object. Give [] to use the global RandStream.
% ds          : Dataset.
% ix          : Logical or numericla index of the rows to attach seeds.
% unique_cols : Cell array of column names. Seeds will be unique only for 
%               rows unique w.r.t. these columns.
% seed_cols   : Char or cell array of column(s) to save the seed (random numbers)
% seed_fun    : Function to apply to the numbers from rand(). Defaults to rand2seed.

% Get ic and n_rand
[~, ~, ic] = unique(ds(ix,:), unique_cols, 'stable');

n_rand = max(ic);

% Get n_seed_cols
if ischar(seed_cols)
    seed_cols = {seed_cols};
elseif ~iscell(seed_cols)
    error('seed_cols must be either a string or cell array of strings!');
end

n_seed_cols = length(seed_cols);

% Get c_rand
if ~isempty(r)
    c_rand = rand(r, n_rand, n_seed_cols);
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