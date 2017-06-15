function [X, is_const_col] = remove_const_columns(X)
% [X, is_const_col] = remove_const_columns(X)

if isempty(X)
    is_const_col = [];
    return;
end

dX = diff(X);
is_const_col = all(dX == 0);
X = X(:, is_const_col);