%% Test 1
p = 1;
assert(isequal_within(invLogit(logit(p)), p, 1e-3));

%% Test 0
p = 0;
assert(isequal_within(invLogit(logit(p)), p, 1e-3));

%% Test 0.5
p = 0.5;
assert(isequal_within(invLogit(logit(p)), p, 1e-3));

%% Test nan
p = nan;
assert(isnan(invLogit(logit(p))));

%% Test empty
p = [];
assert(isempty(invLogit(logit(p))));

%% Test matrix
p = rand(5,3);
assert(all(vVec(isequal_within(invLogit(logit(p)), p, 1e-3))));
