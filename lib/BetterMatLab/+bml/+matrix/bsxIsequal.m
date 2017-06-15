function tf = bsxIsequal(a, b)
% tf = bsxIsequal(a, b)
%
% Works for all types of column vector a and row vector b, including cell.
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.
assert(iscolumn(a));
assert(isrow(b));

n = length(a);
m = length(b);

if isnumeric(a)
    if isnumeric(b)
        tf = bsxEq(a, b);
        return;
    end
else
    try
        tf = bsxStrcmp(a, b);
        return;
    catch
    end
end

tf = false(n, m);
for ii = 1:n
    for jj = 1:m
        tf =  isequal(a(ii), b(jj));
    end
end
