function h = entropy_shannon(p)
% h = entropy_shannon(p)

h = -p .* log2(p);
h(p == 0) = 0;
h = sum(h);