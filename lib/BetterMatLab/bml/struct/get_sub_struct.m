function sub = get_sub_struct(src, prefix)
% sub = get_sub_struct(src, prefix)
%
% See also: set_sub_struct
%
% 2015 (c) Yul Kang.
assert(isstruct(src));
assert(ischar(prefix));

fs = fieldnames(src)';
incl = strcmpStart(prefix, fs);

sub = struct;
len_prefix = length(prefix);
for f = fs(incl)
    f_sub = f{1}((len_prefix+1):end);
    sub.(f_sub) = src.(f{1});
end
return;

%% Test
src = struct; %#ok<UNRCH>
sub_targ = varargin2S({'a', 3, 'b', 4});
src = set_sub_struct(src, varargin2S({'a', 1, 'b', 2}), 'test__');
src = set_sub_struct(src, sub_targ, 'test2__');
sub = get_sub_struct(src, 'test2__');
disp(sub);
passed = isequal(sub, sub_targ);
fprintf('Passed: %d\n', passed);
assert(passed);