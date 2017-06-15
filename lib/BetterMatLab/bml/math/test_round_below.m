f_equal_enough = @(a, b) abs(a - b) < 1e-10;

%% Test min_digit = 0
assert(f_equal_enough(round_below(6543.3456, 0), 6543));

%% Test min_digit = 2
assert(f_equal_enough(round_below(6543.3456, 2), 6500));

%% Test min_digit = 3
assert(f_equal_enough(round_below(6543.3456, 3), 7000));

%% Test min_digit = 4
assert(f_equal_enough(round_below(6543.3456, 4), 10000));

%% Test min_digit = -2
assert(f_equal_enough(round_below(6543.3456, -2), 6543.35));

%% Test min_digit = -4
assert(f_equal_enough(round_below(6543.3456, -4), 6543.3456));