function col = cool1(n)
% Same as cool, but starting from the second blue.
%
% col = cool1(n)
col = cool(n+1);
col = col(2:end, :);