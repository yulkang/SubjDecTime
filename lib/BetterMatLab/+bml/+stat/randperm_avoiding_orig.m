function v = randperm_avoiding_orig(n)
% v = randperm_avoiding_orig(n)
%
% randperm such that ~any(v == (1:n))
% An exception is when n = 1, in which v is just 1.
% Note that this algorithm has rejection probability of 1/n, 
% so doesn't take that much longer than the original randperm.
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

if n == 1
    v = 1;
    return;
end

orig = 1:n;
v = orig;
while any(v == orig)
    v = randperm(n);
end
end