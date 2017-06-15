%% Basic
assert(isequal(strfind_whole('aa bbcc', 'aa'), 1));
assert(isequal(strfind_whole('aa bbcc', 'bb'), []));

%% Ignore one but not the other
assert(isequal(strfind_whole('aa bbcc bb cc', 'bb'), 9));

%% Multiple occurrences
assert(isequal(strfind_whole('aa bb cc bb', 'bb'), [4 10]));

%% Underscore
assert(isequal(strfind_whole('aa bb_cc bb', 'bb'), 10));

%% Number
assert(isequal(strfind_whole('aa bb2cc bb', 'bb'), 10));
