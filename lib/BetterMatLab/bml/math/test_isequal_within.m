%% Smaller within tol
assert(isequal_within(1, 1.05, 0.1));

%% Larger within tol
assert(isequal_within(1, 0.95, 0.1));

%% Smaller outside tol
assert(~isequal_within(1, 1.11, 0.1));

%% Larger outside tol
assert(~isequal_within(1, 0.89, 0.1));

%% Matrix
assert(isequal_within(1 + zeros(3,5), 1.05 + zeros(3,5), 0.1));

%% Exactly equal
assert(isequal_within(1, 1, 0));