function cmat = cc2cmat(cc)
% cmat = cc2cmat(cc)
%
% Convert a cell-vector-of-cell-vectors (latter of various lengths)
% to a cell matrix with each compoenent cell vectors as a row, with
% [] padded at the end.
%
% e.g., convert {{c11, c12, ...}, {c21, c22, ...}, ...}
% to {c11, c12, ..., [], ...; c21, c22, ...; ...}
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.
if ~bml.matrix.is_cc(cc)
    assert(bml.matrix.is_cmat(cc));
    cmat = cc;
    return;
end

% If all are cell arrays, each must be a vector.
len = cellfun(@length, cc);
max_len = max(len);
n = length(cc);

cmat = cell(n, max_len);

for row = 1:n
    cmat(row, 1:len(row)) = cc{row};
end
end