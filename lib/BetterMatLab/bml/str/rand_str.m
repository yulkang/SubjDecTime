function s = rand_str(n, r)
% s = rand_str(n, r)

if isscalar(n), n = [1, n]; end

if exist('r', 'var')
    v = randi(r, 26*2, [1, n]);
else
    v = randi(26*2, [1, n]);
end

up = v <= 26;

s(up)  = 'A' + v(up)  - 1;
s(~up) = 'a' + v(~up) - 27;

s = char(s);