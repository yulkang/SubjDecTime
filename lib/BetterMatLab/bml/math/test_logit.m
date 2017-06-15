%% Test inf
assert(isequal(logit(1), inf));

%% Test -inf
assert(isequal(logit(0), -inf));

%% Test 0
assert(isequal(logit(0.5), 0));

%% Test matrix
assert(isequal(logit(repmat([1, 0.5, 0], [5, 1])), repmat([inf, 0, -inf], [5, 1])));