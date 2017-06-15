function M = pad_cut(M, n)
% M = pad_cut(M, n)

M = M(:, (n+1):(end-n));