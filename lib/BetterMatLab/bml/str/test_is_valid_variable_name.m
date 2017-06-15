%% Alphabets
assert(is_valid_variable_name('a'));
assert(is_valid_variable_name('abc'));

%% Alphabets and numbers
assert(is_valid_variable_name('a12'));

%% Alphabets and underscore
assert(is_valid_variable_name('abc__'));

%% Alphabets, numbers, and underscore
assert(is_valid_variable_name('a12__'));

%% Start with a number
assert(~is_valid_variable_name('1abc'));

%% Start with an underscore
assert(~is_valid_variable_name('_abc'));

%% Empty
assert(~is_valid_variable_name(''));

%% Wrong type
assert(~is_valid_variable_name(double('a')));
